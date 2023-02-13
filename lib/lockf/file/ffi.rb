##
# The {Lock::File::FFI Lock::File::FFI} module provides a one-to-one
# mapping to the C function **lockf**.
module Lock::File::FFI
  require "lockf/lockf.rb.so"
  ##
  # @!method lockf
  #   A low-level interface to the C function **lockf**.
  #
  #   @example
  #     Lock::File::FFI.lockf(5, Lock::File::F_LOCK, 0)
  #
  #   @param [Integer] fd
  #     The file descriptor.
  #
  #   @param [Integer] cmd
  #     An integer represented by one of the following constants:
  #       * {Lock::File::F_LOCK}
  #       * {Lock::File::F_TLOCK}
  #       * {Lock::File::F_ULOCK}
  #       * {Lock::File::F_TEST}
  #
  #   @param [Integer] len
  #     The number of bytes.
  #
  #   @raise (see Lock::File#obtain)
  #
  #   @return [Integer]
  #     Returns 0 when successful.
  #
  #   @see (https://man7.org/linux/man-pages/man3/lockf.3.html) lockf man page (Linux)
  #   @see (https://man.openbsd.org/lockf.3) lockf man page (OpenBSD)
  #   @see (https://www.freebsd.org/cgi/man.cgi?query=lockf) lockf man page (FreeBSD)
end
