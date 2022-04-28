## About

lockf.rb is a Ruby library that provides a Ruby-esque interface to
the POSIX function [lockf](https://man7.org/linux/man-pages/man3/lockf.3.html) -
and provides a low-level interface that can be used to call the function directly.
lockf can be used to lock part of, or all of a file.

The [lockf](https://man7.org/linux/man-pages/man3/lockf.3.html) function can be used to
not only synchronize access to the file it places a lock on - it can also be used to
synchronize access to any shared resource that is being accessed by mutliple processes
at the same time.

## Examples


The examples provide a brief introduction - and don't cover everything. The [API documentation](https://0x1eef.github.io/x/lockf.rb)
is available as a complete reference, and covers parts of the interface not
covered by the examples.

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

## Install

lockf.rb is available as a RubyGem.

    gem install lockf.rb

## License

This project is released under the terms of the MIT license.<br>
See [LICENSE.txt](./LICENSE.txt) for details.
