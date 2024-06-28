# frozen_string_literal: true

class Lock::File
  module FFI
    require "fiddle"
    include Fiddle::Types
    extend self

    ##
    # Provides a Ruby interface for lockf(3)
    #
    # @see https://man.freebsd.org/cgi/man.cgi?query=lockf&sektion=3 lockf(3)
    # @param [Integer, #fileno] fd
    # @param [Integer] function
    # @param [Integer] size
    # @raise [SystemCallError]
    #  Might raise a subclass of SystemCallError
    # @return [Boolean]
    #  Returns true when successful
    def lockf(fd, function, size = 0)
      fileno = fd.respond_to?(:fileno) ? fd.fileno : fd
      Fiddle::Function.new(
        libc["lockf"],
        [INT, INT, INT],
        INT
      ).call(fileno, function, size)
       .zero? || raise(SystemCallError.new("lockf", Fiddle.last_error))
    end

    private

    def libc
      @libc ||= Fiddle.dlopen Dir["/lib/libc.*"].first
    end
  end
end
