##
# The {Lock::File Lock::File} class implements record locking through
# the POSIX function: lockf.
class Lock::File
  require_relative "file/ffi"
  include Lock::File::FFI

  ##
  # @return [<File, Tempfile, #fileno>]
  #  Returns the underlying file.
  attr_reader :file

  ##
  # @param [<File, TempFile, #fileno>] file
  #  The file on which a lock will be placed.
  #
  # @param [Integer] len
  #  The number of bytes to lock. <br>
  #  A value of "0" covers the entire file.
  #
  # @return [Lock::File]
  #  Returns an instance of {Lock::File Lock::File}.
  def initialize(file, len = 0)
    @file = file
    @len = len
    @open_lock = false
  end

  ##
  # Obtains a lock. <br>
  # This method blocks when another process already holds a lock.
  #
  # @raise [SystemCallError]
  #   A number of Errno exceptions can be raised. <br>
  #   Consult your system's lockf man page for details.
  #
  # @return [Integer]
  def obtain
    lockf(@file.fileno, F_LOCK, @len)
  end

  ##
  # Obtains a lock. <br>
  # This method does not block when another process already holds a lock.
  #
  # @raise [Errno::EAGAIN, Errno::EWOULDBLOCK]
  #  When obtaining a lock would block.
  #
  # @raise (see Lock::File#obtain)
  #
  # @return [Integer]
  def obtain_nonblock
    lockf(@file.fileno, F_TLOCK, @len)
  end

  ##
  # Obtains a lock, yields a block, and then releases the lock. <br>
  # This method re-uses the same lock when calls to the method are nested -
  # for example:
  #
  # @example
  #  lock.synchronize { lock.synchronize { .. } }
  #
  # @param [Boolean] nonblock
  #  Determines if a lock will be obtained using #{obtain} or {#obtain_nonblock}.
  #
  # @raise [Errno::EWOULDBLOCK]
  #  When "nonblock" is set to true, and obtaining a lock would block.
  #
  # @raise (see Lock::File#obtain)
  #
  # @return
  def synchronize(nonblock: false)
    return yield if @open_lock
    begin
      nonblock ? obtain_nonblock : obtain
      @open_lock = true
      yield
    ensure
      release
      @open_lock = false
    end
  end

  ##
  # Releases a lock.
  # @raise (see Lock::File#obtain)
  # @return [Integer]
  def release
    lockf(@file.fileno, F_ULOCK, @len)
  end

  ##
  # Returns true when a lock is held by another process.
  # @return [Boolean]
  def locked?
    lockf(@file.fileno, F_TEST, @len)
    false
  rescue Errno::EACCES, Errno::EAGAIN
    true
  end
end
