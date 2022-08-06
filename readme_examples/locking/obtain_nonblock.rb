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
