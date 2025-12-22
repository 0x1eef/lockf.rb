#!/usr/bin/env ruby
# frozen_string_literal: true

require "lockf"
require "tempfile"
file = Tempfile.new("lockf-ffi").tap(&:unlink)
Lockf::FFI.lockf(file, Lockf::F_LOCK, 0)
print "Lock acquired", "\n"
Lockf::FFI.lockf(file, Lockf::F_ULOCK, 0)
print "Lock released", "\n"
file.close

##
# Lock acquired
# Lock released
