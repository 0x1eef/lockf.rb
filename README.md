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

## Features

* Pure Ruby bindings with zero dependencies outside Ruby's standard library
* Temporary locks backed by Tempfile
* Blocking and non-blocking locks
* Low-level abstraction

## Examples

### Lock::File

__Blocking__

The following example creates an anonymous lock that is backed
by an unlinked, randomly named temporary file. The lock attempt
will block until the lock can be acquired, and each process that
is spawned by the parent process will acquire the lock serially:

```ruby
#!/usr/bin/env ruby
require "lockf"

lockf = Lockf.anonymous
5.times do
  Process.detach fork {
    lockf.synchronize do
      print "Lock acquired (pid #{Process.pid})", "\n"
      sleep 5
    end
  }
end

##
# Lock acquired (pid 12345)
# Lock acquired (pid 12346)
# ...
```

__Non-blocking__

The next example creates an anonymous lock whose acquisition
will not block. If the lock cannot be acquired, a subclass of
SystemCallError will be raised:

```ruby
#!/usr/bin/env ruby
require "lockf"

lockf = Lockf.anonymous
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
require "lockf"
require "tempfile"

file = Tempfile.new("lockf-ffi").tap(&:unlink)
Lockf::FFI.lockf(file, Lock::File::F_LOCK, 0)
print "Lock acquired", "\n"
Lockf::FFI.lockf(file, Lock::File::F_ULOCK, 0)
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

