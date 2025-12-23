#!/usr/bin/env ruby
# frozen_string_literal: true

require "lockf"
lockf = Lockf.unlinked_file
lockf.lock_nonblock
print "Lock acquired by parent process (#{Time.now.utc})", "\n"
fork do
  lockf.lock_nonblock
  print "Lock acquired by child process (#{Time.now.utc})", "\n"
rescue Errno::EWOULDBLOCK
  sleep 1
  print "Lock would block", "\n"
  retry
end
sleep 3
lockf.release
Process.wait

##
# Lock acquired by parent process (2023-02-11 19:03:05 UTC)
# Lock would block
# Lock would block
# Lock would block
# Lock acquired by child process (2023-02-11 19:03:08 UTC)
