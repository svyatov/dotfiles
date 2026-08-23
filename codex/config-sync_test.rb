# frozen_string_literal: true

require 'minitest/autorun'
require 'fileutils'
require 'open3'
require 'rbconfig'
require 'tmpdir'

class CodexConfigSyncTest < Minitest::Test
  SCRIPT = File.expand_path('config-sync.rb', __dir__)
  MANAGED = <<~TOML
    personality = "pragmatic"
    model_verbosity = "low"
  TOML

  def setup
    @tmpdir = Dir.mktmpdir
    @managed = File.join(@tmpdir, 'managed.toml')
    @live = File.join(@tmpdir, 'config.toml')
    File.write(@managed, MANAGED)
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def test_replaces_managed_values_and_preserves_other_content
    File.write(@live, <<~TOML)
      model = "gpt-5.6-sol"
      personality = "friendly"
      model_verbosity = "high"

      [projects."/tmp/project"]
      trust_level = "trusted"
    TOML

    stdout, stderr, status = run_sync

    assert status.success?, stderr
    assert_equal <<~TOML, File.read(@live)
      model = "gpt-5.6-sol"
      personality = "pragmatic"
      model_verbosity = "low"

      [projects."/tmp/project"]
      trust_level = "trusted"
    TOML
    assert_includes stdout, 'Updated personality: "friendly" -> "pragmatic"'
    assert_includes stdout, 'Updated model_verbosity: "high" -> "low"'
  end

  def test_inserts_missing_values_before_the_first_table
    File.write(@live, <<~TOML)
      model = "gpt-5.6-sol"

      [tui]
      theme = "dracula"
    TOML

    _stdout, stderr, status = run_sync

    assert status.success?, stderr
    assert_equal <<~TOML, File.read(@live)
      model = "gpt-5.6-sol"
      personality = "pragmatic"
      model_verbosity = "low"

      [tui]
      theme = "dracula"
    TOML
  end

  def test_dry_run_reports_changes_without_writing
    original = "personality = \"friendly\"\n"
    File.write(@live, original)

    stdout, stderr, status = run_sync('--dry-run')

    assert status.success?, stderr
    assert_equal original, File.read(@live)
    assert_includes stdout, 'Would update personality: "friendly" -> "pragmatic"'
    assert_includes stdout, 'Would add model_verbosity = "low"'
  end

  def test_status_fails_when_values_drift
    File.write(@live, "personality = \"friendly\"\n")

    stdout, _stderr, status = run_sync('--status')

    refute status.success?
    assert_includes stdout, 'personality: "friendly" -> "pragmatic"'
    assert_includes stdout, 'model_verbosity: absent -> "low"'
  end

  def test_status_succeeds_when_values_match
    File.write(@live, MANAGED)

    stdout, stderr, status = run_sync('--status')

    assert status.success?, stderr
    assert_equal "Codex config is synchronized.\n", stdout
  end

  def test_refuses_duplicate_top_level_keys
    File.write(@live, <<~TOML)
      personality = "friendly"
      personality = "none"
    TOML

    _stdout, stderr, status = run_sync

    refute status.success?
    assert_includes stderr, 'duplicate top-level key: personality'
  end

  def test_creates_an_absent_live_config
    @live = File.join(@tmpdir, '.codex', 'config.toml')

    stdout, stderr, status = run_sync

    assert status.success?, stderr
    assert_equal MANAGED, File.read(@live)
    assert_includes stdout, 'Added personality = "pragmatic"'
    assert_includes stdout, 'Added model_verbosity = "low"'
  end

  def test_inserts_after_a_final_line_without_a_newline
    File.write(@live, 'model = "gpt-5.6-sol"')

    _stdout, stderr, status = run_sync

    assert status.success?, stderr
    assert_equal <<~TOML, File.read(@live)
      model = "gpt-5.6-sol"
      personality = "pragmatic"
      model_verbosity = "low"
    TOML
  end

  def test_replaces_a_single_quoted_managed_value
    File.write(@live, "personality = 'friendly'\nmodel_verbosity = 'high'\n")

    _stdout, stderr, status = run_sync

    assert status.success?, stderr
    assert_equal MANAGED, File.read(@live)
  end

  private

  def run_sync(*arguments)
    Open3.capture3(
      {
        'CODEX_CONFIG_SOURCE' => @managed,
        'CODEX_CONFIG_LIVE' => @live
      },
      RbConfig.ruby,
      SCRIPT,
      *arguments
    )
  end
end
