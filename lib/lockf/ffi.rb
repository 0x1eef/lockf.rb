# frozen_string_literal: true

class Lockf
  module FFI
    require "fiddle"
    include Fiddle::Types
    extend self

    ##
    # The common superclass for FFI errors
    Error = Class.new(RuntimeError)

    ##
    # The error raised when dlopen(3) fails
    LinkError = Class.new(Error)

    @libc ||= begin
      globs = %w[
        /lib/libc.so.*
        /usr/lib/libc.so.*
        /lib/x86_64-linux-gnu/libc.so.*
        /lib/i386-linux-gnu/libc.so.*
      ]
      Fiddle.dlopen(Dir[*globs].first)
    rescue => ex
      raise LinkError, "link of libc had an error", cause: ex
    end unless defined?(@libc)

    @function = Fiddle::Function.new(
      @libc["lockf"],
      [INT, INT, INT],
      INT
    ) unless defined?(@function)

    ##
    # Provides a Ruby interface for lockf(3)
    # @see https://man.freebsd.org/cgi/man.cgi?query=lockf&sektion=3 lockf(3)
    # @param [Integer, #fileno] fd
    # @param [Integer] fn
    # @param [Integer] size
    # @raise [SystemCallError]
    #  Might raise a subclass of SystemCallError
    # @return [Boolean]
    #  Returns true when successful
    def lockf(fd, fn, size = 0)
      fileno = fd.respond_to?(:fileno) ? fd.fileno : fd
      Lockf::FFI.function.call(fileno, fn, size).zero? ||
        raise(SystemCallError.new("lockf", Fiddle.last_error))
    end

    ##
    # @api private
    def self.function = @function
  end
end
