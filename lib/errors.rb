module BERT
  class Client
    class RPCError < StandardError; end
    class NoSuchModule < RPCError; end
    class NoSuchFunction < RPCError; end
    class UnknownError < RPCError; end
    class InvalidResponse < RPCError; end
    class BadHeader < RPCError; end
    class BadData < RPCError; end

    class UserError < RPCError
      attr_accessor :code, :reason

      def initialize(msg = nil, klass=nil, code=0)
        @klass = klass
        @code = code
        super(msg)
      end
    end
    
    class ConnectionError < StandardError
      attr_reader :host, :port
      def initialize(host, port)
        @host, @port = host, port
        super("Unable to connect to #{host}:#{port}")
      end
    end

    class ConnectionLostError < StandardError
      attr_reader :host, :port
      def initialize(host, port)
        @host, @port = host, port
        super("Connection lost to #{host}:#{port}")
      end
    end
  end
end