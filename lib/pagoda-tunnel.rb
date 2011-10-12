require 'timeout'
require 'socket'
require 'openssl'  

module Pagoda
  class Tunnel
    VERSION = "0.1.0"
    # Your code goes here...

    def initialize(type, user, pass, app, instance, port = 3306)
      @type     = type
      @user     = user
      @pass     = pass
      @app      = app
      @instance = instance
      @port     = port
    end

    def port_available?(ip, port)
      begin
        Timeout::timeout(1) do
          begin
            s = TCPSocket.new(ip, port)
            s.close
            return false
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
            return true
          end
        end
      rescue Timeout::Error
      end
      return true
    end

    def next_available_port(start_port)
      until port_available?("0.0.0.0", start_port)
        # puts "port #{start_port} was not available"
        start_port += 1
      end
      start_port
    end
    
    def start
      
      [:INT, :TERM].each do |sig|
        Signal.trap(sig) do
          puts "Tunnel Closed."
          puts "-----------------------------------------------"
          puts
          exit
        end
      end
      
      remote_host = "tunnel.pagodabox.com" # switch to tunnel.pagodabox.com
      remote_port = 443

      max_threads     = 20
      threads         = []

      chunk           = 4096*4096

      # puts "start TCP server"
      # puts "+> Opening Tunnel"
      @port = next_available_port(@port)
      retrys = 0
      begin
        proxy_server = TCPServer.new('0.0.0.0', @port)
      rescue Exception => e
        @port += 1
        retry if retrys < 4
        # puts "unable to connect to #{@port}. The algorithm is broken"
        exit
      end
      
      puts
      puts "Tunnel Established!  Accepting connections on :"
      puts "-----------------------------------------------"
      puts
      puts "HOST : 127.0.0.1 (or localhost)"
      puts "PORT : #{@port}"
      puts "USER : (found in pagodabox dashboard)"
      puts "PASS : (found in pagodabox dashboard)"
      puts
      puts "-----------------------------------------------"
      puts "(note : ctrl-c To close this tunnel)"
      
      loop do

        # puts "start a new thread for every client connection"
        threads << Thread.new(proxy_server.accept) do |client_socket|
          begin
            # puts "client connection"
            begin
              server_socket         = TCPSocket.new(remote_host, remote_port)
              ssl_context           = OpenSSL::SSL::SSLContext.new()  
              ssl_socket            = OpenSSL::SSL::SSLSocket.new(server_socket, ssl_context)
              ssl_socket.sync_close = true
              ssl_socket.connect
            rescue Errno::ECONNREFUSED
              # puts "connection refused"
              client_socket.close
              raise
            end

            # puts "authenticate"
            if ssl_socket.readpartial(chunk) == "auth"
              # puts "authentication"
              # puts "auth=#{@type}:#{@user}:#{@pass}:#{@app}:#{@instance}" 
              ssl_socket.write "auth=#{@type}:#{@user}:#{@pass}:#{@app}:#{@instance}" 
              if ssl_socket.readpartial(chunk) == "success"
                # puts "successful connection"
              else
                # puts "failed connection"
              end
            else
              # puts "danger will robbinson! abort!"
            end

            loop do
              # puts "wait for data on either socket"
              (ready_sockets, dummy, dummy) = IO.select([client_socket, ssl_socket])

              # puts "full duplex connection until data stream ends"
              begin
                ready_sockets.each do |socket|
                  data = socket.readpartial(chunk)
                  if socket == client_socket
                    # puts "SERVER <== CLIENT"
                    ssl_socket.write data
                    ssl_socket.flush
                  else
                    # puts "SERVER ==> CLIENT"
                    client_socket.write data
                    client_socket.flush
                  end
                end
              rescue EOFError
                break
              end
            end

          rescue StandardError => error
          end
          client_socket.close rescue StandardError
          ssl_socket.close rescue StandardError
        end

        # puts "clean up the dead threads, and wait until we have available threads"
        threads = threads.select { |thread| thread.alive? ? true : (thread.join; false) }
        while threads.size >= max_threads
          sleep 1
          threads = threads.select { |thread| thread.alive? ? true : (thread.join; false) }
        end
      end
    end
  end
end
