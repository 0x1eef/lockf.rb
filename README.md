## About

lockf.rb is a Ruby library that provides a Ruby-esque interface to
the POSIX function: [lockf](https://man7.org/linux/man-pages/man3/lockf.3.html) - and provides a low-level interface that can be used to call the function directly.
lockf can be used to lock part of, or all of a file.

lockf can be used to not only synchronize access to the
file it places a lock on - it can be used to synchronize
access to any shared resource that is being accessed by mutliple processes at the same time.


