require "lockf"
require "tempfile"

file = Tempfile.new("lockf-ffi").tap(&:unlink)
Lock::FFI.lockf(file.fileno, Lock::FFI::F_LOCK, 0)
print "Lock acquired", "\n"
Lock::FFI.lockf(file.fileno, Lock::FFI::F_ULOCK, 0)
print "Lock released", "\n"
file.close
