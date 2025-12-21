## About

lockf.rb offers Ruby bindings for the advisory-mode lock
provided by the
[lockf(3)](https://man.freebsd.org/cgi/man.cgi?query=lockf&sektion=3)
function. It is similar to flock(2) in spirit but it also has semantic 
differences that can be desirable when used across the fork(2) boundary 
and that is usually the main reason to use this library.

## Background

The primary difference between lockf(3) and flock(2) in practical terms 
is that locks created with lockf(3) persist across fork(2). That is to 
say, if a parent process acquires a lock and then forks a child process, 
the child process will have to wait until the parent process releases 
the lock before it can acquire the same lock. This is not the case with 
flock(2).

The technical explanation is that lockf(3) creates a lock that is owned
by the process rather than the open file description (as is the case with 
flock(2)). Since a lock belongs to the process, it cannot be acquired
by more than one process at a time, and with flock(2) a lock can be 
acquired as long as the open file description is different, which is the
case after fork(2). 

To the best of my knowledge, Ruby does not provide built-in support for
lockf(3) so the library fills that gap.

## Examples

### Lock::File

__Blocking__

[Lock::File#lock](http://0x1eef.github.io/x/lockf.rb/Lock/File.html#lock-instance_method)
can be used to acquire a lock.
[Lock::File.temporary_file](http://0x1eef.github.io/x/lockf.rb/Lock/File.html#temporary_file-class_method)
returns a lock for an unlinked temporary file.
[Lock::File#lock](http://0x1eef.github.io/x/lockf.rb/Lock/File.html#lock-instance_method)
will block when another
process has acquired a lock beforehand:

```ruby
#!/usr/bin/env ruby
require "lock/file"

lockf = Lock::File.temporary_file
lockf.lock
print "Lock acquired by parent process (#{Time.now.utc})", "\n"
fork do
  print "Child process waiting on lock (#{Time.now.utc})", "\n"
  lockf.lock
  print "Lock acquired by child process (#{Time.now.utc})", "\n"
end
sleep(3)
lockf.release
Process.wait

##
# Lock acquired by parent process (2023-02-11 16:43:15 UTC)
# Child process waiting on lock (2023-02-11 16:43:15 UTC)
# Lock acquired by child process (2023-02-11 16:43:18 UTC)
```

__Non-blocking__

[Lock::File#lock_nonblock](http://0x1eef.github.io/x/lockf.rb/Lock/File.html#lock_nonblock-instance_method)
can be used to acquire a lock without blocking. When it is found
that acquiring a lock would block the method will raise an
exception (`Errno::EAGAIN` / `Errno::EWOULDBLOCK`) instead:

```ruby
#!/usr/bin/env ruby
require "lock/file"

lockf = Lock::File.temporary_file
lockf.lock_nonblock
print "Lock acquired by parent process (#{Time.now.utc})", "\n"
fork do
  lockf.lock_nonblock
  print "Lock acquired by child process (#{Time.now.utc})", "\n"
rescue Errno::EWOULDBLOCK
  sleep 1
  print "Lock would block", "\n"
  retry
end
sleep 3
lockf.release
Process.wait

##
# Lock acquired by parent process (2023-02-11 19:03:05 UTC)
# Lock would block
# Lock would block
# Lock would block
# Lock acquired by child process (2023-02-11 19:03:08 UTC)
```

### Lock::File::FFI

__lockf__

[Lock::File::FFI.lockf](http://0x1eef.freebsd.home.network/x/lockf.rb/Lock/File/FFI.html#lockf-instance_method)
provides a direct interface to
[lockf(3)](https://man.freebsd.org/cgi/man.cgi?query=lockf&sektion=3)
that is more or less equivalent to how the function would be called
from C:

```ruby
#!/usr/bin/env ruby
require "lock/file"
require "tempfile"

file = Tempfile.new("lockf-ffi").tap(&:unlink)
Lock::File::FFI.lockf(file, Lock::File::F_LOCK, 0)
print "Lock acquired", "\n"
Lock::File::FFI.lockf(file, Lock::File::F_ULOCK, 0)
print "Lock released", "\n"
file.close

##
# Lock acquired
# Lock released
```

## Documentation

A complete API reference is available at
[0x1eef.github.io/x/lockf.rb](https://0x1eef.github.io/x/lockf.rb)

## Install

lockf.rb can be installed via rubygems.org:

    gem install lockf.rb

## Sources

* [GitHub](https://github.com/0x1eef/lockf.rb#readme)
* [GitLab](https://gitlab.com/0x1eef/lockf.rb#about)

## License

[BSD Zero Clause](https://choosealicense.com/licenses/0bsd/)
<br>
See [LICENSE](./LICENSE)

