module Lock
end unless defined?(Lock)

##
# {Lock::File Lock::File} provides an object-oriented
# [lockf(3)](https://man.freebsd.org/cgi/man.cgi?query=lockf&sektion=3)
# interface
class Lock::File
  require_relative "file/version"
  require_relative "file/ffi"
  require_relative "file/constants"

  include FFI
  include Constants

  ##
  # Accepts the same parameters as Tempfile.new
  # @example
  #  lockf = Lock::File.temporary_file
  #  lockf.lock
  #  # ...
  # @return [Lock::File]
  #  Returns a {Lock::File Lock::File} for a random,
  #  unlinked temporary file
  def self.temporary_file(...)
    require "tempfile" unless defined?(Tempfile)
    Lock::File.new Tempfile.new(...).tap(&:unlink)
  end
  
  class << self
    alias_method :anonymous, :temporary_file
  end

  ##
  # @return [<#fileno>]
  #  Returns a file handle
  attr_reader :file

  ##
  # @param [<#fileno>] file
  # @param [Integer] size
  # @return [Lock::File]
  #  Returns an instance of {Lock::File Lock::File}
  def initialize(file, size = 0)
    @file = file
    @size = size
  end

  ##
  # Acquire lock (blocking)
  # @see https://man.freebsd.org/cgi/man.cgi?query=lockf&sektion=3 lockf(3)
  # @raise [SystemCallError]
  #  Might raise a subclass of SystemCallError
  # @return [Boolean]
  #  Returns true when successful
  def lock
    try(function: F_LOCK)
  end

  ##
  # Acquire lock (non-blocking)
  # @see https://man.freebsd.org/cgi/man.cgi?query=lockf&sektion=3 lockf(3)
  # @raise [SystemCallError]
  #  Might raise a subclass of SystemCallError
  # @return [Boolean]
  #  Returns true when successful
  def lock_nonblock
    try(function: F_TLOCK)
  end

  ##
  # Release lock
  # @see https://man.freebsd.org/cgi/man.cgi?query=lockf&sektion=3 lockf(3)
  # @raise [SystemCallError]
  #  Might raise a subclass of SystemCallError
  # @return [Boolean]
  #  Returns true when successful
  def release
    try(function: F_ULOCK)
  end

  ##
  # Acquire a blocking lock, yield, and finally release  the lock
  # @example
  #  lockf = Lock::File.temporary_file
  #  lockf.synchronize do
  #    # critical section
  #  end
  # @raise [SystemCallError]
  #  Might raise a subclass of SystemCallError
  # @return [Object]
  #  Returns the return value of the block
  def synchronize
    locked = false
    lock
    locked = true
    yield
  ensure
    release if locked
  end

  ##
  # Acquire a non-blocking lock, yield, and finally release the lock
  # @note
  #  If the lock cannot be acquired, an exception is raised immediately
  # @example
  #  lockf = Lock::File.temporary_file
  #  lockf.synchronize! do
  #    # critical section
  #  end
  # @raise [SystemCallError]
  #  Might raise a subclass of SystemCallError
  # @return [Object]
  #  Returns the return value of the block
  def synchronize!
    locked = false
    lock_nonblock
    locked = true
    yield
  ensure
    release if locked
  end

  ##
  # @return [Boolean]
  #  Returns true when lock can be acquired
  def lockable?
    try(function: F_TEST)
    true
  rescue Errno::EACCES, Errno::EAGAIN, Errno::EWOULDBLOCK
    false
  end

  ##
  # Closes {Lock::File#file Lock::File#file}
  # @example
  #  # Equivalent to:
  #  lockf = Lock::File.temporary_file
  #  lockf.file.close
  # @return [void]
  def close
    @file.respond_to?(:close) ? @file.close : nil
  end

  private

  def try(function: F_LOCK, attempts: 3)
    lockf(@file, function, @size)
  rescue Errno::EINTR => ex
    attempts -= 1
    (attempts == 0) ? raise(ex) : retry
  end
end
