# frozen_string_literal: true

require_relative "setup"
require "test/cmd"

class Lock::File::ReadmeTest < Test::Unit::TestCase
  def test_lockfile_blocking_variant
    r = ruby(readme_example("1_lock_file_blocking_variant.rb"))
    ["Lock acquired by parent process \(.+\)\n",
     "Child process waiting on lock \(.+\)\n",
     "Lock acquired by child process \(.+\)\n"
    ].each { assert_match Regexp.new(_1), r.stdout }
  end

  def test_lockfile_nonblocking_variant
    r = ruby(readme_example("2_lock_file_nonblocking_variant.rb"))
    ["Lock acquired by parent process \(.+\)\n",
     "(Lock would block\n){3,4}",
     "Lock acquired by child process \(.+\)\n"
    ].each { assert_match Regexp.new(_1), r.stdout }
  end

  def test_ffi_lockf_blocking_variant
    assert_equal "Lock acquired\nLock released\n",
                 ruby(readme_example("3_ffi_lockf_blocking_variant.rb")).stdout
  end

  def test_ffi_lockf_nonblocking_variant
    assert_equal "Lock acquired\nLock released\n",
                 ruby(readme_example("4_ffi_lockf_nonblocking_variant.rb")).stdout
  end

  private

  def ruby(*argv)
    cmd("ruby", *argv)
  end

  def readme_example(example_name)
    File.join(__dir__, "..", "share", "lockf.rb", "examples", example_name)
  end
end
