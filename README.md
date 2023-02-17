## About

lockf.rb is a C extension that provides a Ruby interface to
[lockf(3)](https://man.freebsd.org/cgi/man.cgi?query=lockf&sektion=3).
[lockf(3)](https://man.freebsd.org/cgi/man.cgi?query=lockf&sektion=3)
implements an advisory-mode lock that can be placed on select regions
of a file, or on the entire contents of a file. The lock can be used to
synchronize access to a file between multiple processes, or be used
more generally to synchronize access to any shared resource being accessed
by multiple processes at the same time. In the general case, the lock can
provide something similar to a mutex that works across multiple processes
rather than multiple threads.

## Examples

### Lock::File

The [`Lock::File`](#apidocs) class provides a Ruby-oriented interface to
[lockf(3)](https://man.freebsd.org/cgi/man.cgi?query=lockf&sektion=3).

#### Blocking lock

The `Lock::File#lock` method can be used to acquire a lock. The method will
block when another process has acquired a lock beforehand:

```ruby
require "lockf"
require "tempfile"

file  = Tempfile.new("lockf").tap(&:unlink)
lockf = Lock::File.new(file)
lockf.lock
print "Lock acquired by parent process (#{Time.now.utc})", "\n"
pid = fork {
  print "Child process waiting on lock (#{Time.now.utc})", "\n"
  lockf.lock
  print "Lock acquired by child process (#{Time.now.utc})", "\n"
}
sleep(3)
lockf.release
Process.wait(pid)
file.close

##
# Lock acquired by parent process (2023-02-11 16:43:15 UTC)
# Child process waiting on lock (2023-02-11 16:43:15 UTC)
# Lock acquired by child process (2023-02-11 16:43:18 UTC)
```

#### Non-blocking lock

The `Lock::File#lock_nonblock` method can be used to acquire a lock
without blocking. When it is found that acquiring a lock would block
the method will raise an exception (ie `Errno::EAGAIN` /`Errno::EWOULDBLOCK`)
instead:

```ruby
require "lockf"
require "tempfile"

file  = Tempfile.new("lockf").tap(&:unlink)
lockf = Lock::File.new(file)
lockf.lock_nonblock
print "Lock acquired by parent process (#{Time.now.utc})", "\n"
pid = fork do
  lockf.lock_nonblock
  print "Lock acquired by child process (#{Time.now.utc})", "\n"
rescue Errno::EWOULDBLOCK
  print "Lock would block", "\n"
  sleep 1
  retry
end
sleep 3
lockf.release
Process.wait(pid)
file.close

##
# Lock acquired by parent process (2023-02-11 19:03:05 UTC)
# Lock would block
# Lock would block
# Lock would block
# Lock acquired by child process (2023-02-11 19:03:08 UTC)
```

### Lock::FFI

The [`Lock::FFI`](#apidocs) module provides a direct interface to
[lockf(3)](https://man.freebsd.org/cgi/man.cgi?query=lockf&sektion=3)
that is more or less equivalent to how the function would be called
from C.

#### Blocking lock

```ruby
require "lockf"
require "tempfile"

file = Tempfile.new("lockf-ffi").tap(&:unlink)
Lock::FFI.lockf(file.fileno, Lock::FFI::F_LOCK, 0)
print "Lock acquired", "\n"
Lock::FFI.lockf(file.fileno, Lock::FFI::F_ULOCK, 0)
print "Lock released", "\n"
file.close

##
# Lock acquired
# Lock released
```

#### Non-blocking lock

```ruby
require "lockf"
require "tempfile"

file = Tempfile.new("lockf-ffi").tap(&:unlink)
Lock::FFI.lockf(file.fileno, Lock::FFI::F_TLOCK, 0)
print "Lock acquired", "\n"
Lock::FFI.lockf(file.fileno, Lock::FFI::F_ULOCK, 0)
print "Lock released", "\n"
file.close

##
# Lock acquired
# Lock released
```

## Sources

* [Source code (GitHub)](https://github.com/0x1eef/lockf.rb#readme)
* [Source code (GitLab)](https://gitlab.com/0x1eef/lockf.rb#about)

## Install

lockf.rb is distributed as a RubyGem through its git repositories. <br>
[GitHub](https://github.com/0x1eef/lockf.rb),
and
[GitLab](https://gitlab.com/0x1eef/lockf.rb)
are available as sources.

## License

[BSD Zero Clause](https://choosealicense.com/licenses/0bsd/).
<br>
See [LICENSE](./LICENSE).

