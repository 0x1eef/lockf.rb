require "lockf"
require "tempfile"

file = Tempfile.new("lockf-ffi").tap(&:unlink)
LockFile.lockf(file.fileno, LockFile::F_LOCK, 0)
print "Lock acquired", "\n"
LockFile.lockf(file.fileno, LockFile::F_ULOCK, 0)
print "Lock released", "\n"
file.close

##
# Lock acquired
# Lock released
