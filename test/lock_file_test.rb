# frozen_string_literal: true

require_relative "setup"

class Lockf::Test < Test::Unit::TestCase
  attr_reader :file
  attr_reader :lockf

  def setup
    @file = Tempfile.new("lockf-test").tap(&:unlink)
    @lockf = Lockf.new(file)
  end

  def teardown
    file.close
  end

  ##
  # LockFile#lock
  def test_lock
    assert_equal true, lockf.lock
  ensure
    lockf.release
  end

  def test_lock_in_fork
    pid = fork_sleep { lockf.lock }
    sleep(0.1)
    assert_raises(Errno::EWOULDBLOCK) { lockf.lock_nonblock }
  ensure
    Process.kill("KILL", pid)
    lockf.release
  end

  ##
  # LockFile#lock_nonblock
  def test_lock_nonblock
    assert_equal true, lockf.lock_nonblock
  ensure
    lockf.release
  end

  def test_lock_nonblock_in_fork
    pid = fork_sleep { lockf.lock_nonblock }
    sleep(0.1)
    assert_raises(Errno::EWOULDBLOCK) { lockf.lock_nonblock }
  ensure
    Process.kill("KILL", pid)
    lockf.release
  end

  ##
  # LockFile#lockable?
  def test_lockable?
    pid = fork_sleep { lockf.lock }
    sleep(0.1)
    assert_equal false, lockf.lockable?
  ensure
    Process.kill("KILL", pid)
    lockf.release
  end

  ##
  # LockFile.temporary_file
  def test_temporary_file
    lockf = Lockf.temporary_file
    assert_equal true, lockf.lock
    assert_equal true, lockf.release
  ensure
    lockf.file.close
  end

  private

  def fork_sleep
    fork do
      yield
      sleep
    end
  end
end
