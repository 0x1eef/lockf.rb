##
# The {Lock::FFI Lock::FFI} module provides a one-to-one
# mapping to the POSIX function **lockf**.
module Lock::FFI
  require "lockf/lockf.rb.so"
  ##
  # @!method lockf
  #   A low-level interface to the POSIX function **lockf**.
  #
  #   @example
  #     Lock::FFI.lockf(5, Lock::F_LOCK, 0)
  #   @param [Integer] fd
  #     The file descriptor.
  #   @param [Integer] cmd
  #     An integer represented by one of the following constants:
  #       * {Lock::F_LOCK}
  #       * {Lock::F_TLOCK}
  #       * {Lock::F_ULOCK}
  #       * {Lock::F_TEST}
  #   @param [Integer] len
  #     The number of bytes.
  #   @raise [SystemCallError]
  #     A number of Errno exceptions can be raised. <br>
  #     See the man pages for details.
  #   @return [Integer]
  #     Returns 0 when successful.
  #   @see (https://man7.org/linux/man-pages/man3/lockf.3.html) lockf man page (Linux)
  #   @see (https://man.openbsd.org/lockf.3) lockf man page (OpenBSD)
end
