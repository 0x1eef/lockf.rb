##
# The [`Lock::FFI`](#apidocs) module provides a direct interface to
# [lockf(3)](https://man.freebsd.org/cgi/man.cgi?query=lockf&sektion=3)
# that is more or less equivalent to how the function would be called
# from C.
module Lock::FFI
  require "lockf/lockf.rb.so"
  ##
  # @!method lockf
  #   @example
  #     Lock::FFI.lockf(5, Lock::FFI::F_LOCK, 0)
  #
  #   @param [Integer] fd
  #     A number that represents a file descriptor
  #
  #   @param [Integer] cmd
  #     {Lock::FFI::F_LOCK}, {Lock::FFI::F_TLOCK}, {Lock::FFI::F_ULOCK}, or
  #     {Lock::FFI::F_TEST}
  #
  #   @param [Integer] len
  #     A number of bytes that represents a section of a file to perform
  #     a command on
  #
  #   @return [Integer]
  #     Returns 0 on success
  #
  #   @see (https://man7.org/linux/man-pages/man3/lockf.3.html) lockf man page (Linux)
  #   @see (https://man.openbsd.org/lockf.3) lockf man page (OpenBSD)
  #   @see (https://www.freebsd.org/cgi/man.cgi?query=lockf) lockf man page (FreeBSD)
end
