##
# The [`Lock::File`](#apidocs) class provides a Ruby-oriented interface to
# [lockf(3)](https://man.freebsd.org/cgi/man.cgi?query=lockf&sektion=3).
class Lock::File
  require_relative "ffi"
  include Lock::FFI

  ##
  # @return [<File, Tempfile, #fileno>]
  #  Returns a file object.
  attr_reader :file

  ##
  # @param [<File, TempFile, #fileno>] file
  #  The file to place a lock on.
  #
  # @param [Integer] len
  #  The number of bytes to place a lock on.
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
  # @raise [Errno::EBADF]
  # @raise [Errno::EDEADLK]
  # @raise [Errno::EINTR]
  # @raise [Errno::ENOLCK]
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
  # @raise [Errno::EAGAIN]
  # @raise [Errno::EBADF]
  # @raise [Errno::ENOLCK]
  # @raise [Errno::EINVAL]
  # @return [Integer]
  def lock_nonblock
    lockf(@file.fileno, F_TLOCK, @len)
  end

  ##
  # Release a lock
  # @raise [Errno::EBADF]
  # @raise [Errno::ENOLCK]
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
