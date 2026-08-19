#!/usr/bin/env ruby
# frozen_string_literal: true

# Reconcile ~/.claude/settings.json with the copy in this repo.
#
# This file can't be symlinked like the rest of the dotfiles: it has several
# writers. Claude Code rewrites it (/config, /model, plugin toggles), and
# supacode injects its own hooks into it. supacode is a native app, so it
# writes atomically, which replaces a symlink with a regular file.
#
# So both copies drift, in both directions, and neither one is authoritative.
# This script diffs them and asks which side wins for every difference it
# cannot resolve mechanically. Nothing is added or removed without an answer.

require 'json'
require 'set'

REPO_SETTINGS = ENV.fetch('SETTINGS_SYNC_REPO', File.join(__dir__, 'settings.json'))
LIVE_SETTINGS = ENV.fetch('SETTINGS_SYNC_LIVE', File.join(Dir.home, '.claude', 'settings.json'))

# Hooks owned by other tools. They are guarded no-ops when their app is absent,
# but they churn on every app update, so the repo copy stays clean. Add a
# marker here when another tool starts injecting.
FOREIGN_HOOK = /supacode-managed-hook|orca/i

ABSENT = Object.new
def ABSENT.inspect = '(absent)'

### Paths
#########
# A path is an array of segments. A String segment indexes a Hash. An
# [:elem, s] segment is one element of an array of strings, which is compared
# as a set so a single added permission is its own difference rather than a
# 58-line array replacement.

def elem?(seg) = seg.is_a?(Array)

def string_array?(value)
  value.is_a?(Array) && !value.empty? && value.all?(String)
end

def flatten(obj, prefix = [], out = {})
  case obj
  when Hash
    if obj.empty?
      out[prefix] = {}
    else
      obj.each { |k, v| flatten(v, prefix + [k], out) }
    end
  when Array
    if string_array?(obj)
      obj.each { |s| out[prefix + [[:elem, s]]] = s }
    else
      # Opaque: an empty array, or an array of non-strings. Outside `hooks`
      # this file has never had one, so it is a guard, not a feature.
      out[prefix] = obj
    end
  else
    out[prefix] = obj
  end
  out
end

def unflatten(entries)
  root = {}
  entries.each do |path, value|
    node = root
    path.each_with_index do |seg, i|
      if elem?(seg)
        node << seg[1] unless node.include?(seg[1])
        break
      elsif i == path.length - 1
        node[seg] = value
      else
        node[seg] ||= elem?(path[i + 1]) ? [] : {}
        node = node[seg]
      end
    end
  end
  root
end

def render_path(path)
  path.map { |seg| elem?(seg) ? '[]' : seg }.join('.').sub('.[]', '[]')
end

### Hooks
#########
# hooks = { event => [ { "matcher" => m, "hooks" => [ hook, ... ] } ] }
# A hook's identity is (event, matcher group, command). Everything else about
# it (timeout, statusMessage) can differ and is a difference to resolve.

def split_hooks(obj)
  rest = obj.reject { |k, _| k == 'hooks' }
  [rest, obj['hooks'] || {}]
end

def group_key(group) = group.key?('matcher') ? [:matcher, group['matcher']] : [:none]

def hook_entries(hooks)
  hooks.flat_map do |event, groups|
    groups.flat_map do |group|
      (group['hooks'] || []).map do |hook|
        { event: event, group: group_key(group), hook: hook }
      end
    end
  end
end

def foreign_hook?(hook) = FOREIGN_HOOK.match?(hook['command'].to_s)

def foreign?(entry) = foreign_hook?(entry[:hook])

def hook_id(entry) = [entry[:event], entry[:group], entry[:hook]['command']]

def strip_foreign(hooks)
  hooks.each_with_object({}) do |(event, groups), out|
    kept = groups.filter_map do |group|
      own = (group['hooks'] || []).reject { |hook| foreign_hook?(hook) }
      own.empty? ? nil : group.merge('hooks' => own)
    end
    out[event] = kept unless kept.empty?
  end
end

# Rebuild `hooks` from the source structure rather than from a flat list, so
# groups that happen to share a matcher stay separate and foreign hooks keep
# their exact position. `decisions` maps a hook id to its replacement, or to
# nil to drop it. `additions` are hooks the other side won outright.
def rebuild_hooks(source, decisions, additions)
  out = source.each_with_object({}) do |(event, groups), acc|
    kept = groups.filter_map do |group|
      hooks = (group['hooks'] || []).filter_map do |hook|
        id = [event, group_key(group), hook['command']]
        decisions.key?(id) ? decisions[id] : hook
      end
      hooks.empty? ? nil : group.merge('hooks' => hooks)
    end
    acc[event] = kept unless kept.empty?
  end

  additions.each do |entry|
    groups = (out[entry[:event]] ||= [])
    group = groups.find { |g| group_key(g) == entry[:group] }
    unless group
      group = entry[:group][0] == :matcher ? { 'matcher' => entry[:group][1], 'hooks' => [] } : { 'hooks' => [] }
      groups << group
    end
    group['hooks'] += [entry[:hook]]
  end
  out
end

def hook_label(entry)
  command = entry[:hook]['command'].to_s.gsub(/\s+/, ' ')
  matcher = entry[:group][0] == :matcher ? entry[:group][1].to_s : ''
  "hooks.#{entry[:event]}#{matcher.empty? ? '' : "[#{matcher}]"}  #{command[0, 60]}"
end

### Differences
###############
Difference = Struct.new(:key, :label, :repo, :live, :kind, keyword_init: true) do
  def to_s = label
end

def settings_differences(repo, live)
  r = flatten(repo)
  l = flatten(live)
  (r.keys + l.keys).uniq.filter_map do |key|
    next if r.key?(key) && l.key?(key) && r[key] == l[key]

    Difference.new(
      key: key,
      label: render_path(key),
      repo: r.fetch(key, ABSENT),
      live: l.fetch(key, ABSENT),
      kind: :setting
    )
  end
end

def hook_differences(repo_entries, live_entries)
  r = repo_entries.to_h { |e| [hook_id(e), e] }
  l = live_entries.to_h { |e| [hook_id(e), e] }
  (r.keys + l.keys).uniq.filter_map do |id|
    a = r[id]
    b = l[id]
    next if a && b && a[:hook] == b[:hook]

    Difference.new(
      key: id,
      label: hook_label(a || b),
      repo: a ? a[:hook] : ABSENT,
      live: b ? b[:hook] : ABSENT,
      kind: :hook
    )
  end
end

# Claude Code deletes enabledPlugins entries for plugins it cannot currently
# resolve, so a missing key there is never a decision: disabling a plugin
# writes false, it does not remove the entry. Always keep the repo entry.
def pruned_plugin?(diff)
  diff.kind == :setting &&
    diff.key.length == 2 && diff.key[0] == 'enabledPlugins' &&
    diff.live.equal?(ABSENT)
end

### Applying resolutions
########################
# resolutions maps a Difference to :repo, :live or :skip. :skip leaves each
# file exactly as it was, so the difference survives to the next run.

def apply_settings(repo, live, resolutions)
  r = flatten(repo)
  l = flatten(live)
  by_key = resolutions.to_h { |diff, choice| [diff.key, choice] }
  repo_out = []
  live_out = []

  (r.keys + (l.keys - r.keys)).each do |key|
    case by_key[key]
    when nil # identical on both sides
      repo_out << [key, r[key]]
      live_out << [key, l[key]]
    when :repo
      next unless r.key?(key)

      repo_out << [key, r[key]]
      live_out << [key, r[key]]
    when :live
      next unless l.key?(key)

      repo_out << [key, l[key]]
      live_out << [key, l[key]]
    when :skip
      repo_out << [key, r[key]] if r.key?(key)
      live_out << [key, l[key]] if l.key?(key)
    end
  end

  [unflatten(repo_out), unflatten(live_out)]
end

def apply_hooks(repo_hooks, live_hooks, resolutions)
  repo_decisions = {}
  live_decisions = {}
  repo_additions = []
  live_additions = []

  resolutions.each do |diff, choice|
    next if choice == :skip

    id = diff.key
    winner = choice == :repo ? diff.repo : diff.live
    [[diff.repo, repo_decisions, repo_additions],
     [diff.live, live_decisions, live_additions]].each do |current, decisions, additions|
      if current.equal?(ABSENT)
        additions << { event: id[0], group: id[1], hook: winner } unless winner.equal?(ABSENT)
      else
        decisions[id] = winner.equal?(ABSENT) ? nil : winner
      end
    end
  end

  [rebuild_hooks(repo_hooks, repo_decisions, repo_additions),
   rebuild_hooks(live_hooks, live_decisions, live_additions)]
end

### Safety
##########
# Refuse to write anything that adds or drops a path nobody asked about.
def assert_no_silent_change!(repo_in, live_in, repo_out, live_out, resolutions)
  before = Set.new(flatten(repo_in).keys) | Set.new(flatten(live_in).keys)
  after = Set.new(flatten(repo_out).keys) | Set.new(flatten(live_out).keys)

  intended = Set.new
  resolutions.each do |diff, choice|
    next unless diff.kind == :setting

    intended << diff.key if (choice == :repo && diff.repo.equal?(ABSENT)) ||
                            (choice == :live && diff.live.equal?(ABSENT))
  end

  lost = before - after - intended
  raise "refusing to write, these paths would be dropped unasked: #{lost.map { |k| render_path(k) }.join(', ')}" unless lost.empty?

  invented = after - before
  raise "refusing to write, these paths were invented: #{invented.map { |k| render_path(k) }.join(', ')}" unless invented.empty?
end

def assert_foreign_hooks_intact!(live_hooks_in, live_hooks_out)
  before = hook_entries(live_hooks_in).select { |e| foreign?(e) }
  after = hook_entries(live_hooks_out).select { |e| foreign?(e) }
  return if before == after

  raise "refusing to write, foreign hooks changed: #{before.length} live, #{after.length} would be written"
end

# Own hooks: nothing appears or disappears unasked, and the two sides end up
# with the same set apart from the ones answered `skip`.
def assert_hooks_agree!(repo_hooks_out, live_hooks_out, resolutions)
  raise 'refusing to write, a foreign hook reached the repo copy' if hook_entries(repo_hooks_out).any? { |e| foreign?(e) }

  skipped = resolutions.select { |_, choice| choice == :skip }.keys.map(&:key).to_set
  r = hook_entries(repo_hooks_out).to_h { |e| [hook_id(e), e[:hook]] }
  l = hook_entries(live_hooks_out).reject { |e| foreign?(e) }.to_h { |e| [hook_id(e), e[:hook]] }
  disagree = ((r.keys + l.keys).uniq - skipped.to_a).reject { |id| r[id] == l[id] }
  return if disagree.empty?

  raise "refusing to write, hooks still disagree at: #{disagree.map { |id| id[0] }.join(', ')}"
end

def assert_sides_agree!(repo_out, live_out, resolutions)
  skipped = resolutions.select { |_, choice| choice == :skip }.keys.map(&:key).to_set
  r = flatten(repo_out)
  l = flatten(live_out)
  disagree = ((r.keys + l.keys).uniq - skipped.to_a).reject { |k| r[k] == l[k] && r.key?(k) == l.key?(k) }
  return if disagree.empty?

  raise "refusing to write, sides still disagree at: #{disagree.map { |k| render_path(k) }.join(', ')}"
end

### Pipeline
############
# Split both files, classify every difference, hand the ones needing a human
# to `resolver`, apply the answers, then refuse to return anything that lost
# or invented a path. main and the test both go through here.
Plan = Struct.new(:repo_out, :live_out, :asked, :auto, :foreign, keyword_init: true)

def reconcile(repo_in, live_in, &resolver)
  repo_rest, repo_hooks = split_hooks(repo_in)
  live_rest, live_hooks = split_hooks(live_in)

  # The repo copy never holds foreign hooks. The live copy keeps them exactly
  # where they are, so they are stripped for the diff and left alone otherwise.
  repo_own = strip_foreign(repo_hooks)
  live_own = strip_foreign(live_hooks)
  live_foreign = hook_entries(live_hooks).select { |e| foreign?(e) }

  differences = settings_differences(repo_rest, live_rest) +
                hook_differences(hook_entries(repo_own), hook_entries(live_own))
  auto, asked = differences.partition { |d| pruned_plugin?(d) }

  return Plan.new(asked: asked, auto: auto, foreign: live_foreign) if resolver.nil?

  resolutions = auto.to_h { |d| [d, :repo] }.merge(asked.empty? ? {} : resolver.call(asked))
  setting_res = resolutions.select { |d, _| d.kind == :setting }
  hook_res = resolutions.select { |d, _| d.kind == :hook }

  repo_out_rest, live_out_rest = apply_settings(repo_rest, live_rest, setting_res)
  repo_out_hooks, live_out_hooks = apply_hooks(repo_own, live_hooks, hook_res)

  assert_no_silent_change!(repo_rest, live_rest, repo_out_rest, live_out_rest, setting_res)
  assert_sides_agree!(repo_out_rest, live_out_rest, setting_res)
  assert_foreign_hooks_intact!(live_hooks, live_out_hooks)
  assert_hooks_agree!(repo_out_hooks, live_out_hooks, hook_res)

  Plan.new(
    repo_out: with_hooks(repo_out_rest, repo_out_hooks),
    live_out: with_hooks(live_out_rest, live_out_hooks),
    asked: asked, auto: auto, foreign: live_foreign
  )
end

def with_hooks(rest, hooks) = hooks.empty? ? rest : rest.merge('hooks' => hooks)

### Output
##########
def deep_sort(obj)
  case obj
  when Hash then obj.keys.sort.to_h { |k| [k, deep_sort(obj[k])] }
  when Array then obj.map { |e| deep_sort(e) }
  else obj
  end
end

def render(obj) = "#{JSON.pretty_generate(deep_sort(obj))}\n"

def read_settings(path)
  raise "not found: #{path}" unless File.file?(path)

  JSON.parse(File.read(path))
rescue JSON::ParserError => e
  raise "not valid JSON: #{path} (#{e.message})"
end

def show(value) = value.equal?(ABSENT) ? '(absent)' : JSON.generate(value)

### CLI
#######
def prompt(differences)
  resolutions = {}
  all = nil

  differences.each_with_index do |diff, i|
    if all
      resolutions[diff] = all
      next
    end

    puts ''
    puts "(#{i + 1}/#{differences.length}) #{diff.label}"
    puts "      repo: #{show(diff.repo)}"
    puts "      live: #{show(diff.live)}"

    loop do
      print '  [r]epo  [l]ive  [s]kip  [R]epo-all  [L]ive-all  [q]uit > '
      answer = $stdin.gets
      abort 'No answer, nothing written.' if answer.nil?

      case answer.strip
      when 'r' then resolutions[diff] = :repo
      when 'l' then resolutions[diff] = :live
      when 's' then resolutions[diff] = :skip
      when 'R' then resolutions[diff] = all = :repo
      when 'L' then resolutions[diff] = all = :live
      when 'q' then abort 'Aborted, nothing written.'
      else
        next
      end
      break
    end
  end

  resolutions
end

def write_out(path, content, dry_run)
  # Compare parsed, not byte for byte. Claude Code writes the live file in its
  # own key order; reordering it is not a change worth making.
  unchanged = File.exist?(path) && begin
    JSON.parse(File.read(path)) == JSON.parse(content)
  rescue JSON::ParserError
    false
  end

  if unchanged
    puts "Already up to date: #{path}"
  elsif dry_run
    puts "[DRY RUN] Would update: #{path}"
  else
    # Write through the destination rather than replacing it. Replacing the
    # file is exactly how this stopped being a symlink in the first place.
    File.write(path, content)
    puts "Updated: #{path}"
  end
end

def main(argv)
  mode = :reconcile
  dry_run = false

  argv.each do |arg|
    case arg
    when '--status' then mode = :status
    when '--dry-run' then dry_run = true
    when '--help', '-h' then mode = :help
    else abort "Unknown option: #{arg}"
    end
  end

  if mode == :help
    puts <<~USAGE
      Usage: settings-sync.rb [--status] [--dry-run]

      Reconciles ~/.claude/settings.json with claude/settings.json in this repo.
      That file has several writers, so it is synced rather than symlinked.

      With no options it lists every difference and asks which side wins, then
      writes both files. Nothing is added or removed without an answer.

      Options:
          --status    List the differences and exit, write nothing
          --dry-run   Ask as usual, report what would be written, write nothing
          --help, -h  Show this help message

      Two differences resolve without asking, and are reported when they do:
          - hooks matching #{FOREIGN_HOOK.source} stay out of the repo and stay live
          - enabledPlugins entries the runtime pruned keep their repo value

      Paths:
          repo  #{REPO_SETTINGS}
          live  #{LIVE_SETTINGS}
    USAGE
    return 0
  end

  repo_in = read_settings(REPO_SETTINGS)
  live_in = read_settings(LIVE_SETTINGS)

  survey = reconcile(repo_in, live_in)

  puts "Foreign hooks kept live, never committed: #{survey.foreign.length}"
  survey.foreign.each { |e| puts "  #{hook_label(e)}" }
  unless survey.auto.empty?
    puts "Plugin entries the runtime pruned, keeping the repo value: #{survey.auto.length}"
    survey.auto.each { |d| puts "  #{d.label} = #{show(d.repo)}" }
  end

  if mode == :status
    if survey.asked.empty?
      puts 'Differences needing an answer: none'
    else
      puts "Differences needing an answer: #{survey.asked.length}"
      survey.asked.each do |d|
        puts "  #{d.label}"
        puts "      repo: #{show(d.repo)}"
        puts "      live: #{show(d.live)}"
      end
    end
    return 0
  end

  puts 'No differences to resolve.' if survey.asked.empty?
  plan = reconcile(repo_in, live_in) { |asked| prompt(asked) }

  puts ''
  write_out(REPO_SETTINGS, render(plan.repo_out), dry_run)
  write_out(LIVE_SETTINGS, render(plan.live_out), dry_run)
  0
end

if __FILE__ == $PROGRAM_NAME
  begin
    exit main(ARGV)
  rescue RuntimeError => e
    abort "ERROR: #{e.message}"
  end
end
