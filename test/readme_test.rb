# frozen_string_literal: true

require_relative "setup"
require "test/cmd"

class LockFile::ReadmeTest < Test::Unit::TestCase
  include Test::Cmd

  def test_ffi_lockf_blocking_variant
    assert_equal "Lock acquired\nLock released\n",
                 readme_example("3_ffilockf_blocking_variant.rb").stdout
  end

  def test_ffi_lockf_nonblocking_variant
    assert_equal "Lock acquired\nLock released\n",
                 readme_example("4_ffilockf_nonblocking_variant.rb").stdout
  end

  private

  def readme_example(path)
    examples_dir = File.join(Dir.getwd, "share", "lockf.rb", "examples")
    example = File.join(examples_dir, path)
    cmd "bundle exec ruby #{example}"
  end
end
