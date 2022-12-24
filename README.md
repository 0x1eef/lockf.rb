## About

lockf.rb provides a Ruby interface to the __lockf__ function that's available on UNIX,
and UNIX-like operating systems. The
[FreeBSD](https://www.freebsd.org/cgi/man.cgi?query=lockf&sektion=3),
[OpenBSD](https://man.openbsd.org/lockf.3), and
[Linux](https://man7.org/linux/man-pages/man3/lockf.3.html)
manual pages describe the  __lockf__ function in detail.
[lockf.rb's API documentation](https://0x1eef.github.io/x/lockf.rb)
covers the Ruby interface in detail. lockf.rb is distributed as a RubyGem
through its git repositories. See [INSTALL](#install) for installation instructions.

## Examples

### Lock

#### `#obtain`

The following example demonstrates the `Lock::File#obtain` method, and
how after a parent process obtains a lock the child process is blocked until
the parent process releases the lock - only then can a lock can be obtained
by the child process:

```ruby
require "lockf"
require "tempfile"

def lock_in_fork(lock)
  fork do
    print "Lock 2 waiting", "\n"
    lock.obtain
        .then { print "Lock 2 obtained", "\n" }
        .then { lock.release }
        .then { print "Lock 2 released", "\n" }
  end
end

lock = Lock::File.new(Tempfile.new('example').tap(&:unlink))
pid  = nil
lock.obtain
    .then { print "Lock 1 obtained", "\n" }
    .then { pid = lock_in_fork(lock) }
    .then { sleep(1.5) }
    .then { lock.release }
    .then { print "Lock 1 released", "\n" }
    .then { Process.wait(pid) }
    .then { lock.file.close }

##
# Lock 1 obtained
# Lock 2 waiting
# Lock 1 released
# Lock 2 obtained
# Lock 2 released
```

#### `#obtain_nonblock`

The following example demonstates the non-blocking counterpart to `#obtain`: `#obtain_nonblock`. The
primary difference between the blocking, and non-blocking variant is that when obtaining a lock would block `Errno::EWOULDBLOCK` is raised:


```ruby
require "lockf"
require "tempfile"

def lock_in_fork(lock)
  fork do
    lock.obtain_nonblock
    print "Lock 2 obtained", "\n"
  rescue Errno::EWOULDBLOCK
    print "Lock 2 would block - wait 0.5s", "\n"
    sleep 0.5
    retry
  end
end

lock = Lock::File.new(Tempfile.new('example').tap(&:unlink))
pid  = nil
lock.obtain
    .then { print "Lock 1 obtained", "\n" }
    .then { pid = lock_in_fork(lock) }
    .then { sleep(1.5) }
    .then { lock.release }
    .then { print "Lock 1 released", "\n" }
    .then { Process.wait(pid) }
    .then { lock.file.close }

##
# Lock 1 obtained
# Lock 2 would block - wait 0.5s
# Lock 2 would block - wait 0.5s
# Lock 2 would block - wait 0.5s
# Lock 1 released
# Lock 2 obtained
```

## <a id='INSTALL'>Install</a>

lockf.rb is available as a RubyGem.

    gem install lockf.rb

## License

This project is released under the terms of the MIT license.<br>
See [LICENSE.txt](./LICENSE.txt) for details.
