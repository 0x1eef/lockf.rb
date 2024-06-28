# frozen_string_literal: true

class Lock::File
  # The constants found in this module are defined
  # by unistd.h. Their documentation can be found in
  # the
  # [lockf(3)](https://man.freebsd.org/cgi/man.cgi?query=lockf&sektion=3)
  # man page
  module Constants
    F_ULOCK = 0x0
    F_LOCK  = 0x1
    F_TLOCK = 0x2
    F_TEST  = 0x3
  end
end
