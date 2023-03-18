require_relative "setup"
class LockFile::Test < Test::Unit::TestCase
  include Timeout
  attr_reader :lockf

  def setup
    @lockf = LockFile.new(file)
  end

  def teardown
    file.close
  end

  ##
  # Lock::File#lock tests
  def test_lock
    assert_equal 0, lockf.lock
  ensure
    lockf.release
  end

  def test_lock_in_fork
    Process.wait fork {
      lockf.lock
      Process.kill("SIGINT", Process.ppid)
      sleep(1)
    }
  rescue Interrupt
    assert_raises(Timeout::Error) { timeout(0.5) { lockf.lock } }
  ensure
    lockf.release
  end

  ##
  # Lock::File#lock_nonblock tests
  def test_lock_nonblock
    assert_equal 0, lockf.lock_nonblock
  ensure
    lockf.release
  end

  def test_lock_nonblock_in_fork
    Process.wait fork {
      lockf.lock_nonblock
      Process.kill("SIGINT", Process.ppid)
      sleep(1)
    }
  rescue Interrupt
    assert_raises(Errno::EAGAIN) { lockf.lock_nonblock }
  ensure
    lockf.release
  end

  ##
  # Lock::File#locked? tests
  def test_locked?
    lockf.lock
    Process.wait fork { lockf.locked? ? exit(0) : exit(1) }
    assert_equal 0, $?.exitstatus
  ensure
    lockf.release
  end

  private

  def file
    @file ||= Tempfile.new("lockf-test").tap(&:unlink)
  end
end
