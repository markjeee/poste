require 'yaml'

module Palmade::Poste
  class Config
    DEFAULT_CONFIG = {
      :working_path => '/var/lib/poste'.freeze,

      # relative to the working directory
      :tmp_path => 'tmp'.freeze,
      :log_path => 'log'.freeze,

      # spool directory
      :spool => {
        :path => 'spool'.freeze,
        :dirs => 64
      },

      # SMTP settings
      :smtp => {
        :listen => [
                    "127.0.0.1:2525".freeze,
                    "127.0.0.1:2552".freeze
                   ]
      },

      # default mongo settings
      :mongo => {
        :host => '127.0.0.1'.freeze,
        :port => 27017,
        :user => 'root'.freeze,
        :password => nil,
        :database => 'poste'.freeze
      },

      # SMTP relay
      :relay => {
        :default => [ "127.0.0.1:25" ]
      }
    }

    def self.parse(config_file)
      new(YAML.load_file(config_file))
    end

    def initialize(config_hash)
      parse_config(config_hash)
    end

    def [](k)
      @config[k]
    end

    def include?(k)
      @config.include?(k)
    end

    def keys
      @config.keys
    end

    def size
      @config.size
    end

    def diagnostic_dump
      <<DIAG
  Working path: #{working_path}
  Spool path: #{@config[:spool_path]}
  Log path: #{@config[:log_path]}
  Tmp path: #{@config[:tmp_path]}
DIAG
    end

    def working_path
      File.expand_path(@config[:working_path])
    end

    def spool
      @config[:spool]
    end

    def mongo
      @config[:mongo]
    end

    def smtp
      @config[:smtp]
    end

    def relay
      @config[:relay]
    end

    protected

    def parse_config(config_hash)
      ch = Utils.symbolize_keys(config_hash)

      @config = { }
      DEFAULT_CONFIG.each do |k, v|
        if ch.include?(k)
          case v
          when Hash
            @config[k] = config_merge(v, Utils.symbolize_keys(ch[k]))
          else
            @config[k] = ch[k]
          end
        else
          @config[k] = v
        end
      end

      @config
    end

    def config_merge(from, to)
      unless to.nil?
        from.merge(to)
      else
        { }.merge(from)
      end
    end
  end
end
