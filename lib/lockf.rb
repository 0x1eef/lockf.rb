##
# lockf.rb is a C extension that provides a Ruby interface to lockf(3). lockf(3)
# implements an advisory-mode lock that can be placed on select regions of a
# file, or on the entire contents of a file. The lock can be used to synchronize
# access to a file between multiple processes, or be used more generally to
# synchronize access to a shared resource being accessed by multiple processes
# at the same time. When used generally, the lock can provide something similar
# to a mutex that works across multiple processes rather than multiple threads.
class LockFile
  require_relative "lockf.rb.so"
  include Fcntl

  ##
  # @!method LockFile.lockf
  #   @example
  #     LockFile.lockf(5, Lockf::F_LOCK, 0)
  #
  #   @param [Integer] fd
  #     A number that represents a file descriptor
  #
  #   @param [Integer] cmd
  #     {LockFile::F_LOCK}, {LockFile::F_TLOCK}, {LockFile::F_ULOCK}, or
  #     {LockFile::F_TEST}
  #
  #   @param [Integer] len
  #     A number of bytes that represents a section of a file to perform
  #     a command on
  #
  #   @return [Integer]
  #     Returns 0 on success
  #
  #   @see (https://man7.org/linux/man-pages/man3/lockf.3.html) lockf man page (Linux)
  #   @see (https://man.openbsd.org/lockf.3) lockf man page (OpenBSD)
  #   @see (https://www.freebsd.org/cgi/man.cgi?query=lockf) lockf man page (FreeBSD)

  ##
  # @return [String]
  def self.version
    "0.7.0"
  end

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
  # @return [LockFile]
  #  Returns an instance of {LockFile LockFile}.
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
    LockFile.lockf(@file.fileno, F_LOCK, @len)
  rescue Errno::EINTR => ex
    attempts += 1
    (attempts == 3) ? raise(ex) : retry
  end

  ##
  # Acquire a lock (non-blocking)
  # @raise [Errno::EAGAIN]
  # @raise [Errno::EBADF]
  # @raise [Errno::ENOLCK]
  # @raise [Errno::EINVAL]
  # @return [Integer]
  def lock_nonblock
    LockFile.lockf(@file.fileno, F_TLOCK, @len)
  end

  ##
  # Release a lock
  # @raise [Errno::EBADF]
  # @raise [Errno::ENOLCK]
  # @return [Integer]
  def release
    LockFile.lockf(@file.fileno, F_ULOCK, @len)
  end

  ##
  # @return [Boolean]
  #  Returns true when a lock has been acquired by another process.
  def locked?
    LockFile.lockf(@file.fileno, F_TEST, @len)
    false
  rescue Errno::EACCES, Errno::EAGAIN
    true
  end
end
