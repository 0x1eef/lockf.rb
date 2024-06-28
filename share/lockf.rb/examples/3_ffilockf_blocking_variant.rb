#!/usr/bin/env ruby
# frozen_string_literal: true

require "lock/file"
require "tempfile"
file = Tempfile.new("lockf-ffi").tap(&:unlink)
Lock::File::FFI.lockf(file, Lock::File::F_LOCK, 0)
print "Lock acquired", "\n"
Lock::File::FFI.lockf(file, Lock::File::F_ULOCK, 0)
print "Lock released", "\n"
file.close

##
# Lock acquired
# Lock released
