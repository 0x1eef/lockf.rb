##
# {Lockf Lockf} provides an object-oriented
# [lockf(3)](https://man.freebsd.org/cgi/man.cgi?query=lockf&sektion=3)
# interface
class Lockf
  require_relative "lockf/version"
  require_relative "lockf/ffi"
  require_relative "lockf/constants"

  include FFI
  include Constants

  ##
  # Accepts the same parameters as Tempfile.new
  # @example
  #  lockf = Lockf.unlinked
  #  lockf.lock
  #  # ...
  # @return [Lockf]
  #  Returns a {Lockf Lockf} for a random,
  #  unlinked temporary file
  def self.unlinked(...)
    require "tempfile" unless defined?(Tempfile)
    Lockf.new Tempfile.new(...).tap(&:unlink)
  end

  ##
  # @return [<#fileno>]
  #  Returns a file handle
  attr_reader :file

  ##
  # @param [<#fileno>] file
  # @param [Integer] size
  # @return [Lockf]
  #  Returns an instance of {Lockf Lockf}
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
  #  lockf = Lockf.unlinked_file
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
  #  lockf = Lockf.unlinked_file
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
  # Closes {Lockf#file Lockf#file}
  # @example
  #  # Equivalent to:
  #  lockf = Lockf.unlinked_file
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
