class Lock::File
  include Lock::FFI

  def initialize(file, len = 0)
    @file = file
    @len = len
    @open_lock = false
  end

  def lock
    lockf(@file.fileno, Lock::F_LOCK, @len)
  end

  def lock_nonblock
    lockf(@file.fileno, Lock::F_TLOCK, @len)
  end

  def synchronize(nonblock: false)
    return yield if @open_lock
    begin
      nonblock ? lock_nonblock : lock
      @open_lock = true
      yield
    ensure
      release
      @open_lock = false
    end
  end

  def release
    lockf(@file.fileno, Lock::F_ULOCK, @len)
  end

  def locked?
    lockf(@file.fileno, Lock::F_TEST, @len)
    false
  rescue Errno::EACCES
    true
  end

  def method_missing(m, *args, &b)
    if @file.respond_to?(m)
      @file.public_send(m, *args, &b)
    else
      super
    end
  end

  def respond_to_missing?(m, include_all = false)
    @file.respond_to?(m, false)
  end
end
