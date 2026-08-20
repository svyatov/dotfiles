#!/usr/bin/env ruby
# frozen_string_literal: true

# Run: ruby claude/settings-sync_test.rb
# Silence and exit 0 means pass.

require_relative 'settings-sync'

def check(name)
  yield
rescue StandardError => e
  warn "FAIL #{name}: #{e.message}"
  warn e.backtrace.first(3).map { |l| "     #{l}" }
  @failed = true
end

def eq(actual, expected, what)
  raise "#{what}: expected #{expected.inspect}, got #{actual.inspect}" unless actual == expected
end

SUPACODE = { 'type' => 'command', 'command' => 'printf x # supacode-managed-hook' }.freeze
MARKDOWN = { 'type' => 'command', 'command' => 'markdownlint-cli2', 'timeout' => 15 }.freeze

def hooks_of(event, *hooks) = { event => [{ 'matcher' => '', 'hooks' => hooks }] }

# Answer every asked difference the same way.
def answer_all(choice) = ->(asked) { asked.to_h { |d| [d, choice] } }

# The regression this whole script exists for: a key set live via /config must
# not vanish just because the repo copy predates it.
check 'live-only key survives when live wins' do
  plan = reconcile({ 'model' => 'opus' },
                   { 'model' => 'opus', 'autoCompactWindow' => 200_000 },
                   &answer_all(:live))
  eq plan.asked.length, 1, 'one difference'
  eq plan.repo_out['autoCompactWindow'], 200_000, 'repo gains the key'
  eq plan.live_out['autoCompactWindow'], 200_000, 'live keeps the key'
end

check 'live-only key is removed from live only when repo wins' do
  plan = reconcile({ 'model' => 'opus' },
                   { 'model' => 'opus', 'autoCompactWindow' => 200_000 },
                   &answer_all(:repo))
  eq plan.repo_out.key?('autoCompactWindow'), false, 'repo still lacks it'
  eq plan.live_out.key?('autoCompactWindow'), false, 'live drops it, as answered'
end

check 'repo-only key survives when repo wins' do
  plan = reconcile({ 'tui' => 'compact' }, {}, &answer_all(:repo))
  eq plan.repo_out['tui'], 'compact', 'repo keeps it'
  eq plan.live_out['tui'], 'compact', 'live gains it'
end

check 'skip leaves both sides exactly as they were' do
  repo = { 'model' => 'opus', 'tui' => 'compact' }
  live = { 'model' => 'sonnet', 'autoCompactWindow' => 200_000 }
  plan = reconcile(repo, live, &answer_all(:skip))
  eq plan.repo_out, repo, 'repo untouched'
  eq plan.live_out, live, 'live untouched'
end

check 'a string array element is its own difference' do
  plan = reconcile({ 'permissions' => { 'allow' => %w[a b] } },
                   { 'permissions' => { 'allow' => %w[a b c] } },
                   &answer_all(:live))
  eq plan.asked.length, 1, 'only the added element differs'
  eq plan.asked.first.label, 'permissions.allow[]', 'labelled as a set element'
  eq plan.repo_out['permissions']['allow'], %w[a b c], 'repo order first, addition last'
end

check 'foreign hooks stay live and never reach the repo' do
  repo = { 'hooks' => hooks_of('PostToolUse', MARKDOWN) }
  live = { 'hooks' => hooks_of('PostToolUse', MARKDOWN, SUPACODE) }
  plan = reconcile(repo, live, &answer_all(:repo))
  eq plan.asked.length, 0, 'a foreign hook is never a difference'
  eq plan.repo_out['hooks']['PostToolUse'][0]['hooks'], [MARKDOWN], 'repo keeps only its own'
  eq plan.live_out['hooks']['PostToolUse'][0]['hooks'].include?(SUPACODE), true, 'live keeps the foreign hook'
end

# Rebuilding hooks from a flat list silently merged two groups that happened to
# share a matcher, and moved foreign hooks around inside them.
check 'groups sharing a matcher stay separate, foreign hooks keep their place' do
  own = { 'type' => 'command', 'command' => 'own-hook remind' }
  live_hooks = { 'PreToolUse' => [
    { 'matcher' => '', 'hooks' => [own] },
    { 'matcher' => '', 'hooks' => [SUPACODE] }
  ] }
  plan = reconcile({ 'hooks' => { 'PreToolUse' => [{ 'matcher' => '', 'hooks' => [own] }] } },
                   { 'hooks' => live_hooks },
                   &answer_all(:repo))
  eq plan.asked.length, 0, 'nothing differs'
  eq plan.live_out['hooks'], live_hooks, 'live structure preserved exactly'
  eq plan.repo_out['hooks']['PreToolUse'].length, 1, 'repo keeps its single group'
end

check 'an own hook present on one side only is asked about' do
  repo = { 'hooks' => hooks_of('PreToolUse', { 'type' => 'command', 'command' => 'rtk hook claude' }) }
  plan = reconcile(repo, { 'hooks' => {} }, &answer_all(:repo))
  eq plan.asked.length, 1, 'one hook difference'
  eq plan.live_out['hooks']['PreToolUse'][0]['hooks'].length, 1, 'live gains the hook'
end

check 'a pruned plugin entry is kept without asking' do
  plan = reconcile({ 'enabledPlugins' => { 'a@m' => true, 'b@m' => false } },
                   { 'enabledPlugins' => { 'a@m' => true } },
                   &answer_all(:live))
  eq plan.asked.length, 0, 'nothing to ask'
  eq plan.auto.length, 1, 'one auto-resolved entry'
  eq plan.repo_out['enabledPlugins']['b@m'], false, 'repo entry kept'
end

check 'a disabled plugin toggled live is still a question' do
  plan = reconcile({ 'enabledPlugins' => { 'a@m' => true } },
                   { 'enabledPlugins' => { 'a@m' => false } },
                   &answer_all(:live))
  eq plan.asked.length, 1, 'a value change is never auto-resolved'
  eq plan.repo_out['enabledPlugins']['a@m'], false, 'live value wins'
end

check 'the guard fires when a resolution would drop a path unasked' do
  repo = { 'a' => 1 }
  live = { 'a' => 1, 'b' => 2 }
  dropped = false
  begin
    # A resolver that answers with a Difference the pipeline never asked about
    # leaves the real one unresolved, so `b` would silently disappear.
    reconcile(repo, live) { |_asked| {} }
  rescue RuntimeError => e
    dropped = e.message.include?('sides still disagree')
  end
  eq dropped, true, 'unresolved difference is refused, not written'
end

check 'output formatting is stable and sorted' do
  json = render({ 'b' => 1, 'a' => { 'd' => [], 'c' => 2 } })
  eq json, "{\n  \"a\": {\n    \"c\": 2,\n    \"d\": []\n  },\n  \"b\": 1\n}\n", 'sorted, 2-space, trailing newline'
end

exit 1 if @failed
