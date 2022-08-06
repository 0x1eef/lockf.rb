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
