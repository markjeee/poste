require 'timeout'
require 'socket'

module Palmade::Poste
  module Utils
    def self.symbolize_keys(hash)
      hash.inject({}) do |options, (key, value)|
        options[(key.to_sym rescue key) || key] = value
        options
      end
    end

    def self.is_port_open?(ip, port)
      begin
        ::Timeout::timeout(1) do
          begin
            s = TCPSocket.new(ip, port)
            s.close
            return true
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
            return false
          end
        end
      rescue ::Timeout::Error
      end

      return false
    end
  end
end
