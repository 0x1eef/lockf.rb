##
# The {Lock::File Lock::File} class implements record locking through
# the POSIX function: lockf.
class Lock::File
  require_relative "ffi"
  include Lock::FFI

  ##
  # @return [<File, Tempfile, #fileno>]
  #  Returns the underlying file.
  attr_reader :file

  ##
  # @param [<File, TempFile, #fileno>] file
  #  The file to place a lock on.
  #
  # @param [Integer] len
  #  The number of bytes from +file+ to place a lock on.
  #  A value of "0" covers the entire file.
  #
  # @return [Lock::File]
  #  Returns an instance of {Lock::File Lock::File}.
  def initialize(file, len = 0)
    @file = file
    @len = len
  end

  ##
  # Acquire a lock (blocking)
  #
  # @return [Integer]
  def lock
    attempts ||= 0
    lockf(@file.fileno, F_LOCK, @len)
  rescue Errno::EINTR => ex
    attempts += 1
    (attempts == 3 ? raise(ex) : retry)
  end

  ##
  # Acquire a lock (non-blocking)
  #
  # @raise [Errno::EAGAIN]
  #  When acquiring a lock would block.
  #
  # @return [Integer]
  def lock_nonblock
    lockf(@file.fileno, F_TLOCK, @len)
  end

  ##
  # Release a lock
  #
  # @return [Integer]
  def release
    lockf(@file.fileno, F_ULOCK, @len)
  end

  ##
  # @return [Boolean]
  #  Returns true when a lock has been acquired by another process.
  def locked?
    lockf(@file.fileno, F_TEST, @len)
    false
  rescue Errno::EACCES, Errno::EAGAIN
    true
  end
end
