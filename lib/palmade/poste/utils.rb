require 'timeout'
require 'socket'
require 'digest'

module Palmade::Poste
  module Utils

    def self.cleanup_email(email)
      if email =~ /\A.*\<([^\<\>]+)\>.*\Z/
        $~[1]
      else
        email
      end
    end

    TRX_ID_FORMAT = "%04x%04x%04x%06x%06x%02x%s".freeze
    def self.generate_trx_id
      now = Time.now
      srand(now.usec)

      Digest::SHA2.hexdigest(TRX_ID_FORMAT %
                             [
                              rand(0x0010000),
                              rand(0x0010000),
                              rand(0x0010000),
                              rand(0x1000000),
                              rand(0x1000000),
                              now.day,
                              String(now.usec)
                             ]).freeze
    end

    Chex_format = "%02x".freeze
    def self.to_hex(i)
      sprintf(Chex_format, i)
    end

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
