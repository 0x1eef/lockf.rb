require_relative "setup"
class LockFile::Test < Test::Unit::TestCase
  attr_reader :file, :lockf

  def setup
    @file  = Tempfile.new("lockf-test").tap(&:unlink)
    @lockf = LockFile.new(file)
  end

  def teardown
    file.close
  end

  ##
  # Lock::File#lock
  def test_lock
    assert_equal 0, lockf.lock
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
  # Lock::File#lock_nonblock
  def test_lock_nonblock
    assert_equal 0, lockf.lock_nonblock
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
  # Lock::File#locked?
  def test_locked?
    pid = fork_sleep { lockf.lock }
    sleep(0.1)
    assert_equal true, lockf.locked?
  ensure
    Process.kill("KILL", pid)
    lockf.release
  end

  ##
  # LockFile.temporary_file
  def test_temporary_file
    lockf = LockFile.temporary_file
    assert_equal 0, lockf.lock
    assert_equal 0, lockf.release
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
