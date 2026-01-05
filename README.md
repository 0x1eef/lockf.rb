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
by more than one process at a time, and with flock(2) the acquisition
of a lock won't block as long as the lock is held by the same open file
description, which is the case after fork(2).

To the best of my knowledge, Ruby does not provide built-in support for
lockf(3) so the library fills that gap.

## Features

* Pure Ruby bindings with zero dependencies outside Ruby's standard library
* Temporary, unlinked locks backed by a Tempfile
* Blocking and non-blocking locks
* Low-level abstraction

## Examples

### Synchronization

#### Synchronize

The `synchronize` and `synchronize!` methods provide both a locking,
and non-blocking lock that is released automatically when the
block yields and returns control to the caller. The non-blocking
form (`synchronize!`) raises a subclass of SystemCallError if the
lock cannot be acquired right away.

With all that said, the next example uses the blocking-form of
these two methods, the synchronize method, to create a critical
section that is executed serially by multiple processes. The example
creates a lock that is backed by a randomly named, unlinked temporary
file:

```ruby
#!/usr/bin/env ruby
require "lockf"

pids  = []
lockf = Lockf.unlinked
5.times do
  pids << fork {
    lockf.synchronize do
      print "Lock acquired (pid #{Process.pid})", "\n"
      sleep 5
    end
  }
end
pids.each { Process.wait(it) }

##
# Lock acquired (pid 12345)
# Lock acquired (pid 12346)
# ...
```

#### Procedural

When more control over the lock and release process is required,
the `lock`, `lock_nonblock`, and `release` methods can be used
to acquire and release locks procedurally without a block.

The following example is different from the last one in that it
uses the procedural style, and rather than acquiring a blocking
lock the acquire in this example is non-blocking. When the lock
is found to block, a system-specific subclass of SystemCallError
will be raised:

```ruby
#!/usr/bin/env ruby
require "lockf"

lockf = Lockf.unlinked
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

## Documentation

A complete API reference is available at
[0x1eef.github.io/x/lockf.rb](https://0x1eef.github.io/x/lockf.rb)

## Install

lockf.rb can be installed via rubygems.org:

    gem install lockf.rb

## Sources

* [github.com/@0x1eef](https://github.com/0x1eef/lockf.rb#readme)
* [gitlab.com/@0x1eef](https://gitlab.com/0x1eef/lockf.rb#about)

## License

[BSD Zero Clause](https://choosealicense.com/licenses/0bsd/)
<br>
See [LICENSE](./LICENSE)

