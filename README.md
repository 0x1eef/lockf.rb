## About

lockf.rb is a C extension that provides a Ruby interface to
[lockf(3)](https://man.freebsd.org/cgi/man.cgi?query=lockf&sektion=3).
The
[lockf(3)](https://man.freebsd.org/cgi/man.cgi?query=lockf&sektion=3)
function implements an advisory-mode lock that can be placed on select
regions of a file, or on the entire contents of a file.

[lockf(3)](https://man.freebsd.org/cgi/man.cgi?query=lockf&sektion=3)
can be used to synchronize access to a file between multiple
processes, or be used more generally to synchronize access to a shared
resource being accessed by multiple processes at the same time. When used
generally,
[lockf(3)](https://man.freebsd.org/cgi/man.cgi?query=lockf&sektion=3)
can provide something similar to a mutex that works across multiple
processes rather than multiple threads.

## Examples

### LockFile

The
[`LockFile`](https://0x1eef.github.io/x/lockf.rb/LockFile.html)
class provides an abstract, Ruby-oriented interface to
[lockf(3)](https://man.freebsd.org/cgi/man.cgi?query=lockf&sektion=3).

__Blocking lock__

The `LockFile#lock` method can be used to acquire a lock. The method will
block when another process has acquired a lock beforehand:

```ruby
require "lockf"
require "tempfile"

lockf = LockFile.from_temporary_file
lockf.lock
print "Lock acquired by parent process (#{Time.now.utc})", "\n"
pid = fork do
  print "Child process waiting on lock (#{Time.now.utc})", "\n"
  lockf.lock
  print "Lock acquired by child process (#{Time.now.utc})", "\n"
end
sleep(3)
lockf.release
Process.wait(pid)
lockf.file.close

##
# Lock acquired by parent process (2023-02-11 16:43:15 UTC)
# Child process waiting on lock (2023-02-11 16:43:15 UTC)
# Lock acquired by child process (2023-02-11 16:43:18 UTC)
```

__Non-blocking lock__

The `LockFile#lock_nonblock` method can be used to acquire a lock
without blocking. When it is found that acquiring a lock would block
the method will raise an exception (ie `Errno::EAGAIN` /`Errno::EWOULDBLOCK`)
instead:

```ruby
require "lockf"
require "tempfile"

lockf = LockFile.from_temporary_file
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
lockf.file.close

##
# Lock acquired by parent process (2023-02-11 19:03:05 UTC)
# Lock would block
# Lock would block
# Lock would block
# Lock acquired by child process (2023-02-11 19:03:08 UTC)
```

### LockFile.lockf

The
[`LockFile.lockf`](https://0x1eef.github.io/x/lockf.rb/LockFile.html#lockf-class_method)
method provides a direct interface to
[lockf(3)](https://man.freebsd.org/cgi/man.cgi?query=lockf&sektion=3)
that is more or less equivalent to how the function would be called
from C.

__Blocking lock__

```ruby
require "lockf"
require "tempfile"

file = Tempfile.new("lockf-ffi").tap(&:unlink)
LockFile.lockf(file.fileno, LockFile::F_LOCK, 0)
print "Lock acquired", "\n"
LockFile.lockf(file.fileno, LockFile::F_ULOCK, 0)
print "Lock released", "\n"
file.close

##
# Lock acquired
# Lock released
```

__Non-blocking lock__

```ruby
require "lockf"
require "tempfile"

file = Tempfile.new("lockf-ffi").tap(&:unlink)
LockFile.lockf(file.fileno, LockFile::F_TLOCK, 0)
print "Lock acquired", "\n"
LockFile.lockf(file.fileno, LockFile::F_ULOCK, 0)
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

