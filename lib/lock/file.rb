module Lock
end unless defined?(Lock)

class Lock::File
  require "tmpdir"
  require_relative "file/version"
  require_relative "file/ffi"
  require_relative "file/constants"

  include FFI
  include Constants

  ##
  # @example
  #  lockf = Lock::File.temporary_file
  #  lockf.lock
  #  # ...
  #
  # @param [String] basename
  # @param [String] tmpdir
  # @return [Lock::File]
  #  Returns a {Lock::File Lock::File} for a random,
  #  unlinked temporary file
  def self.from_temporary_file(basename: "lockf", tmpdir: Dir.tmpdir)
    require "tempfile" unless defined?(Tempfile)
    file = Tempfile.new(basename, tmpdir:).tap(&:unlink)
    Lock::File.new(file)
  end
  class << self
    alias_method :temporary_file, :from_temporary_file
  end

  ##
  # @return [<File, Tempfile, #fileno>]
  #  Returns a file handle
  attr_reader :file

  ##
  # @param [<File, TempFile, String, #fileno>] file
  # @param [Integer] len
  # @return [Lock::File]
  #  Returns an instance of {Lock::File Lock::File}
  def initialize(file, len = 0)
    @file = String === file ? File.open(file, "r+") : file
    @len = len
  end

  ##
  # Acquire lock (blocking)
  #
  # @raise [Errno::EBADF]
  # @raise [Errno::EDEADLK]
  # @raise [Errno::EINTR]
  # @raise [Errno::ENOLCK]
  # @return [Boolean]
  def lock
    tries ||= 0
    lockf(@file, F_LOCK, @len)
  rescue Errno::EINTR => ex
    tries += 1
    tries == 3 ? raise(ex) : retry
  end

  ##
  # Acquire lock (non-blocking)
  #
  # @raise [Errno::EAGAIN]
  # @raise [Errno::EBADF]
  # @raise [Errno::ENOLCK]
  # @raise [Errno::EINVAL]
  # @return [Integer]
  def lock_nonblock
    lockf(@file, F_TLOCK, @len)
  end

  ##
  # Release lock
  #
  # @raise [Errno::EBADF]
  # @raise [Errno::ENOLCK]
  # @return [Integer]
  def release
    lockf(@file, F_ULOCK, @len)
  end

  ##
  # @return [Boolean]
  #  Returns true when lock is held by another process
  def locked?
    lockf(@file, F_TEST, @len)
    false
  rescue Errno::EACCES, Errno::EAGAIN
    true
  end

  ##
  # Closes {Lock::File#file Lock::File#file}
  #
  # @example
  #  # Equivalent to:
  #  lockf = Lock::File.temporary_file
  #  lockf.file.close
  # @return [void]
  def close
    return unless @file.respond_to?(:close)
    @file.close
  end
end
