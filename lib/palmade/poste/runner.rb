require 'optparse'

module Palmade::Poste
  class Runner
    include Palmade::Poste::Constants

    attr_reader :options

    def self.run!(argv)
      new.run!(argv)
    end

    def initialize
      @options = { }
      @config = nil
    end

    def run!(argv)
      parse_options.parse!(argv)
      run_cmd!(argv)
    end

    def run_cmd!(argv)
      cmd = argv.first

      unless cmd.nil?
        case cmd.to_sym
        when :start
        when :stop
        when :restart
        else
          raise CmdError, "Unknown command #{cmd}"
        end
      else
        show_help
      end
    end

    protected

    def configure
      config_file = options.include?(:config_file) ? options[:config_file] : DEFAULT_CONFIG_FILE

      @config = Config.parse(config_file)
    end

    def cmd_start
    end

    def cmd_stop
    end

    def cmd_restart
    end

    def show_help
      puts parse_options.help
    end

    def parse_options
      if defined?(@parse_options)
        @parse_options
      else
        @parse_options = OptionParser.new do |opts|
          opts.banner = "Usage: #{PROGRAM_NAME} [options] start|stop|restart|hup"
          opts.separator ''
          opts.on('-c','--config CONFFILE',"The configuration file to read.") do |conf|
            options[:config_file] = conf
          end
        end
      end
    end
  end
end
