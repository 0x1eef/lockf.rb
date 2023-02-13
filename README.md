## About

lockf.rb is a C extension that provides a Ruby interface to
[lockf(3)][https://man.freebsd.org/cgi/man.cgi?query=lockf&sektion=3].

## Examples

### Blocking lock

The `Lock::File#lock` method can be used to acquire a lock. The method will
block when the lock is held by another process who acquired it beforehand:

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

### Non-blocking lock

The `Lock::File#lock_nonblock` method can be used to acquire a lock
in a non-blocking manner. If it is found that acquiring a lock would
block then the method will raise an exception (ie `Errno::EAGAIN` /
`Errno::EWOULDBLOCK`) instead:

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

[BSD Zero Clause](https://choosealicense.com/licenses/0bsd/)
<br>
See [LICENSE](./LICENSE)

