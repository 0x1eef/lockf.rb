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
