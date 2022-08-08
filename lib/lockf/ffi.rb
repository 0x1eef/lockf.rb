##
# The {Lock::FFI Lock::FFI} module provides a one-to-one
# mapping with the POSIX function: lockf. The function is
# available to Ruby as {Lock::FFI#lockf Lock::FFI#lockf}.
module Lock::FFI
  require "lockf/lockf.rb.so"
end
