require 'openssl'
require 'zlib'
require 'bert'

module BERT
  class Client
    class RPCError < StandardError; end
    class NoSuchModule < RPCError; end
    class NoSuchFunction < RPCError; end
    class UserError < RPCError; end
    class UnknownError < RPCError; end
    class InvalidResponse < RPCError; end
    class BadHeader < RPCError; end
    class BadData < RPCError; end

    GZIP_BERP = t[:info, :encoding, [t[:gzip]]]
    ACCEPT_ENCODING_BERP = t[:info, :accept_encoding, [t[:gzip]]]

    @socket_pool ||= {}

    def initialize(opts={}, &block)
      @host = opts[:host] || 'localhost'
      @port = opts[:port] || 9999
      @timeout = opts[:timeout] || 15

      @gzip = opts[:gzip] || false
      @gzip_threshold = opts[:gzip_threshold] || 1024 # bytes
      @gzip_accept_sent = false

      @ssl = opts[:ssl] || false
      @verify_ssl = opts.has_key?(:verify_ssl) ? opts[:verify_ssl] : true

      @socket = get_socket_or_create Thread.current
      
      execute(&block) if block_given?
    end

    def call(mod, fun, *args)
      response = cast_or_call(:call, mod, fun, *args)
      return response[1] if response[0] == :reply

      handle_error(response)
    end

    def cast(mod, fun, *args)
      response = cast_or_call(:cast, mod, fun, *args)
      return nil if response[0] == :noreply

      handle_error(response)
    end

    private
    # Wrapper for both cast and call mechanisms
    def cast_or_call(cc, mod, fun, *args)
      req = t[cc, mod.to_sym, fun.to_sym, args]
      write_berp(req)
      read_response
    end

    def read_response
      gzip_encoded = false
      response = nil

      loop do
        response = read_berp
        break unless response[0] == :info

        # For now we only know how to handle gzip encoding info packets
        if response == GZIP_BERP
          gzip_encoded = true
        else
          raise NotImplementedError, "Only gzip-encoding related info packets are supported in this version of bertclient"
        end
      end

      if gzip_encoded and response[0] == :gzip
        response = BERT.decode(Zlib::Inflate.inflate(response[1]))
      end

      response
    end

    # See bert-rpc.org for error response mechanisms
    def handle_error(response)
      unless response[0] == :error
        raise InvalidResponse, "Expected error response, got: #{response.inspect}"
      end

      type, code, klass, detail, backtrace = response[1]
      case type
      when :server
        if code == 1
          raise NoSuchModule
        elsif code == 2
          raise NoSuchFunction
        else
          raise UnknownError, "Unknown server error: #{response.inspect}"
        end
      when :user
        raise UserError.new("#{klass}: #{detail}\n#{backtrace.join()}")
      when :protocol
        if code == 1
          raise BadHeader
        elsif code == 2
          raise BadData
        else
          raise UnknownError, "Unknown protocol error: #{response.inspect}"
        end
      else
        raise UnknownError, "Unknown error: #{response.inspect}"
      end
    end

    def get_socket_or_create thread
      sock = Client.get_socket(thread)
      unless sock
        sock = Client.set_socket connect(), thread
      end
      sock
    end

    # Creates a socket object which does speedy, non-blocking reads
    # and can perform reliable read timeouts.

    def connect_old
      # Create new tcp socket
      sock = Socket.tcp(@host, @port, Socket::SOCK_STREAM, 0)
      #
      sock.setsockopt Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1
      if @ssl
        sock = OpenSSL::SSL::SSLSocket.new(sock)
        sock.sync_close = true
        sock.connect
        sock.post_connection_check(@host) if @verify_ssl
      end

      if @timeout
        secs = Integer(@timeout)
        usecs = Integer((@timeout - secs) * 1_000_000)
        optval = [secs, usecs].pack("l_2")
        sock.setsockopt Socket::SOL_SOCKET, Socket::SO_RCVTIMEO, optval
        sock.setsockopt Socket::SOL_SOCKET, Socket::SO_SNDTIMEO, optval
      end

      sock
    end

    def connect
      addr = Socket.getaddrinfo(@host, nil, Socket::AF_INET)
      sock = Socket.new(Socket.const_get(addr[0][0]), Socket::SOCK_STREAM, 0)
      sock.setsockopt Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1

      if @ssl
        sock = OpenSSL::SSL::SSLSocket.new(sock)
        sock.sync_close = true
      end

      if @timeout
        secs = Integer(@timeout)
        usecs = Integer((@timeout - secs) * 1_000_000)
        optval = [secs, usecs].pack("l_2")
        sock.setsockopt Socket::SOL_SOCKET, Socket::SO_RCVTIMEO, optval
        sock.setsockopt Socket::SOL_SOCKET, Socket::SO_SNDTIMEO, optval
      end

      sock.connect(Socket.pack_sockaddr_in(@port, addr[0][3]))
      sock.post_connection_check(@host) if @ssl and @verify_ssl
      sock
    end

    # Close socket and clean it up from the pool
    def close
      @socket.close
      Client.del_socket Thread.current
      true
    end

    # Accepts a block, yields the client, closes socket at the end of the block
    def execute
      ret = yield self
      close
      ret
    end

    # Reads a new berp from the socket and returns the decoded object
    def read_berp
      length = @socket.read(4).unpack('N').first
      data = @socket.read(length)
      BERT.decode(data)
    end

    # Accepts a Ruby object, converts to a berp and sends through the socket
    # Optionally sends gzip packet:
    #
    # -> {info, encoding, gzip}
    # -> {gzip, GzippedBertEncodedData}
    def write_berp(obj)
      data = BERT.encode(obj)
      data = negotiate_gzip(data) if @gzip
      @socket.write(Client.create_berp(data))
    end

    def negotiate_gzip(data)
      if not @gzip_accept_sent
        @gzip_accept_sent = true
        @socket.write(Client.create_berp(BERT.encode(ACCEPT_ENCODING_BERP)))
      end

      if data.bytesize > @gzip_threshold
        @socket.write(Client.create_berp(BERT.encode(GZIP_BERP)))
        data = BERT.encode(t[:gzip, Zlib::Deflate.deflate(data)])
      end
      data
    end

    class << self
      # Accepts a string and returns a berp
      def create_berp(data)
        [[data.bytesize].pack('N'), data].join
      end
      
      def get_socket thread
        @socket_pool[thread]
      end

      def set_socket sock, thread
        @socket_pool[thread] = sock
        @socket_pool[thread]
      end

      def del_socket thread
        @socket_pool.delete thread
      end
    end
  end
end