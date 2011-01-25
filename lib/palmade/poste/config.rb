require 'yaml'

module Palmade::Poste
  class Config
    DEFAULT_CONFIG = {
      :working_path => '/var/lib/poste'.freeze,

      # relative to the working directory
      :spool_path => 'spool'.freeze,
      :tmp_path => 'tmp'.freeze,
      :log_path => 'log'.freeze,

      # default mongo settings
      :mongo => {
        :host => '127.0.0.1'.freeze,
        :port => 27017,
        :user => 'root'.freeze,
        :password => nil,
        :database => 'poste'.freeze
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

    protected

    def parse_config(config_hash)
      @config = DEFAULT_CONFIG.merge(Utils.symbolize_keys(config_hash))

      # normalize mongo config
      if @config.include?(:mongo)
        @config[:mongo] = Utils.symbolize_keys(@config[:mongo])
      end

      if @config.include?(:smtp)
        @config[:smtp] = Utils.symbolize_keys(@config[:smtp])
      end
    end
  end
end
