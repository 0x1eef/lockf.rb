##
# lockf.rb is a Ruby library that provides a Ruby-esque interface to
# the POSIX function: [lockf](https://man7.org/linux/man-pages/man3/lockf.3.html) -
# and provides a low-level interface that can be used to call the function
# directly.
module Lock
  require_relative "lockf/file"
  require_relative "lockf/file/version"
end
