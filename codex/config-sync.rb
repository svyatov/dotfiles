#!/usr/bin/env ruby
# frozen_string_literal: true

# Apply the stable Codex preferences from this repository to the live config.
# Codex owns every other setting in ~/.codex/config.toml.

require 'optparse'
require 'fileutils'

SOURCE = ENV.fetch('CODEX_CONFIG_SOURCE', File.join(__dir__, 'config.toml'))
LIVE = ENV.fetch('CODEX_CONFIG_LIVE', File.join(Dir.home, '.codex', 'config.toml'))
MANAGED_KEYS = %w[personality model_verbosity].freeze

options = { dry_run: false, status: false }
OptionParser.new do |parser|
  parser.on('--dry-run') { options[:dry_run] = true }
  parser.on('--status') { options[:status] = true }
end.parse!

def managed_values(path)
  values = {}
  File.readlines(path, chomp: true).each do |line|
    next if line.empty? || line.start_with?('#')

    match = line.match(/\A([a-z_]+)\s*=\s*("(?:[^"\\]|\\.)*")\s*\z/)
    abort "Invalid managed Codex config line: #{line}" unless match

    key, value = match.captures
    abort "Unsupported managed Codex config key: #{key}" unless MANAGED_KEYS.include?(key)
    abort "Duplicate managed Codex config key: #{key}" if values.key?(key)

    values[key] = value
  end

  missing = MANAGED_KEYS - values.keys
  abort "Missing managed Codex config keys: #{missing.join(', ')}" unless missing.empty?

  values
end

def top_level_entries(lines)
  entries = Hash.new { |hash, key| hash[key] = [] }
  table_index = lines.index { |line| line.match?(/^\s*\[/) } || lines.length

  lines.first(table_index).each_with_index do |line, index|
    assignment = line.match(/^\s*(#{MANAGED_KEYS.join('|')})\s*=\s*(.*?)\s*$/)
    next unless assignment

    value = assignment[2].match(/\A("(?:[^"\\]|\\.)*"|'[^']*')\s*(?:#.*)?\z/)
    abort "Invalid top-level Codex config value for #{assignment[1]}" unless value

    entries[assignment[1]] << [index, value[1]]
  end

  entries.each do |key, matches|
    abort "Refusing to edit duplicate top-level key: #{key}" if matches.length > 1
  end

  [entries, table_index]
end

managed = managed_values(SOURCE)
original = File.exist?(LIVE) ? File.read(LIVE) : ''
lines = original.lines
entries, table_index = top_level_entries(lines)
changes = MANAGED_KEYS.filter_map do |key|
  current = entries[key].first&.last
  next if current == managed[key]

  [key, current, managed[key]]
end

if options[:status]
  if changes.empty?
    puts 'Codex config is synchronized.'
    exit
  end

  changes.each do |key, current, wanted|
    puts "#{key}: #{current || 'absent'} -> #{wanted}"
  end
  exit 1
end

if changes.empty?
  puts 'Codex config is synchronized.'
  exit
end

verb = options[:dry_run] ? 'Would' : nil
changes.each do |key, current, wanted|
  action = current ? "update #{key}: #{current} -> #{wanted}" : "add #{key} = #{wanted}"
  puts [verb, action].compact.join(' ').sub(/\Aupdate/, 'Updated').sub(/\Aadd/, 'Added')
end

exit if options[:dry_run]

entries.each do |key, matches|
  next if matches.empty? || managed[key] == matches.first.last

  lines[matches.first.first] = "#{key} = #{managed[key]}\n"
end

missing = MANAGED_KEYS.select { |key| entries[key].empty? }
unless missing.empty?
  insertion_index = table_index
  insertion_index -= 1 while insertion_index.positive? && lines[insertion_index - 1].strip.empty?
  suffix = lines.drop(table_index)
  insertion = missing.map { |key| "#{key} = #{managed[key]}\n" }
  insertion << "\n" unless suffix.empty?
  prefix = lines.first(insertion_index)
  prefix[-1] = "#{prefix.last}\n" if prefix.any? && !prefix.last.end_with?("\n")
  lines = prefix + insertion + suffix
end

FileUtils.mkdir_p(File.dirname(LIVE)) unless Dir.exist?(File.dirname(LIVE))
File.write(LIVE, lines.join)
