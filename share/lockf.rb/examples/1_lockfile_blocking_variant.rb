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
