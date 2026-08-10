#!/usr/bin/env ruby
# frozen_string_literal: true

# Search the brain: BM25 over every OKF note, scored in memory on each run.
#
#   brain-search.rb "query words"   ranked "score<TAB>path<TAB>title<TAB>description"
#   brain-search.rb --self-check    asserts the scoring and corpus rules
#
# Consumers (the UserPromptSubmit hook, the /brain skill) require_relative this
# file and call BrainSearch.search, or read the lines above. BRAIN_DIR overrides
# the brain location.
#
# ponytail: full rescan per run, ~100 ms at the 500-note target. Cache an index
# if the corpus passes ~5000 notes or the hook starts to feel slow.
# ponytail: no stemming, so "gems" misses "gem". Add it (or embeddings) only if
# 05 shows recall is the problem.

require "yaml"

module BrainSearch
  K1 = 1.2
  B = 0.75
  HEAD_WEIGHT = 3 # head text repeated, so a title hit outranks a body hit
  HEAD_KEYS = %w[title aliases tags description].freeze

  Note = Struct.new(:path, :title, :description, :tokens)

  module_function

  def brain_dir = ENV.fetch("BRAIN_DIR") { File.expand_path("~/Projects/Brain") }

  def tokenize(text) = text.to_s.downcase.scan(/[[:alnum:]]+/)

  # A note is any file whose frontmatter carries a non-empty `type`, which
  # excludes index.md, log.md and CLAUDE.md without a path list to maintain.
  # archive/ is retired on purpose and must never be surfaced.
  def load_notes(dir = brain_dir)
    Dir.glob("**/*.md", base: dir).filter_map do |rel|
      next if rel.start_with?("archive/")

      front, body = split_frontmatter(File.read(File.join(dir, rel)))
      next if front.nil? || front["type"].to_s.strip.empty?

      head = HEAD_KEYS.flat_map { front[_1] }.push(rel.delete_suffix(".md"))
      Note.new(File.join(dir, rel), front["title"].to_s, front["description"].to_s,
               tokenize(head.join(" ")) * HEAD_WEIGHT + tokenize(body))
    end
  end

  def split_frontmatter(text)
    return [nil, nil] unless text.start_with?("---\n")

    _, front, body = text.split(/^---[ \t]*$\n/, 3)
    [YAML.safe_load(front.to_s, permitted_classes: [Date, Time]), body]
  rescue Psych::Exception
    [nil, nil]
  end

  # Ranked [score, Note], best first, zero-scoring notes dropped.
  def search(query, notes = load_notes)
    terms = tokenize(query).uniq
    return [] if terms.empty? || notes.empty?

    count = notes.size
    avgdl = notes.sum { _1.tokens.size }.fdiv(count)
    freqs = notes.map { _1.tokens.tally }
    df = terms.to_h { |t| [t, freqs.count { |tf| tf.key?(t) }] }
    idf = terms.to_h { |t| [t, Math.log(1 + (count - df[t] + 0.5) / (df[t] + 0.5))] }

    notes.zip(freqs).filter_map { |note, tf|
      score = terms.sum do |t|
        f = tf.fetch(t, 0)
        next 0.0 if f.zero?

        idf[t] * f * (K1 + 1) / (f + K1 * (1 - B + B * note.tokens.size / avgdl))
      end
      [score, note] if score.positive?
    }.sort_by { -_1.first }
  end
end

def self_check
  require "tmpdir"

  Dir.mktmpdir do |dir|
    write = lambda do |rel, front, body|
      path = File.join(dir, rel)
      Dir.mkdir(File.dirname(path)) unless File.directory?(File.dirname(path))
      File.write(path, "---\n#{front}---\n#{body}")
    end

    write.call("notes/titled.md", "type: note\ntitle: Ferret husbandry\n", "Unrelated body text.\n")
    write.call("notes/bodied.md", "type: note\ntitle: Something else\n", "A passing mention of a ferret here.\n")
    write.call("notes/dated.md", "type: note\ntitle: Dated\ntimestamp: 2026-08-10\n", "Ferret mentioned once.\n")
    write.call("notes/typeless.md", "title: No type\n", "Ferret everywhere in this one.\n")
    write.call("archive/retired.md", "type: note\ntitle: Retired ferret\n", "Ferret ferret ferret.\n")
    File.write(File.join(dir, "index.md"), "# Index\n\nFerret.\n")

    notes = BrainSearch.load_notes(dir)
    paths = notes.map { File.basename(_1.path) }
    raise "corpus wrong: #{paths}" unless paths.sort == %w[bodied.md dated.md titled.md]

    hits = BrainSearch.search("ferret", notes).map { File.basename(_1.last.path) }
    raise "head text must outrank body text: #{hits}" unless hits.first == "titled.md"
    raise "every matching note must rank: #{hits}" unless hits.sort == %w[bodied.md dated.md titled.md]

    raise "unknown terms must return nothing" unless BrainSearch.search("aardvark", notes).empty?
    raise "empty query must return nothing" unless BrainSearch.search("   ", notes).empty?

    unicode = BrainSearch.tokenize("Привет, мир! Two-part")
    raise "tokenizer must handle non-ASCII: #{unicode}" unless unicode == %w[привет мир two part]
  end

  puts "self-check ok"
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.first == "--self-check"
    self_check
  elsif ARGV.empty?
    warn "usage: #{File.basename($PROGRAM_NAME)} \"query words\" | --self-check"
    exit 1
  else
    BrainSearch.search(ARGV.join(" ")).each do |score, note|
      puts format("%.4f\t%s\t%s\t%s", score, note.path, note.title, note.description)
    end
  end
end
