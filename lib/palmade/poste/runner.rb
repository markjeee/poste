require 'fileutils'
require 'optparse'

module Palmade::Poste
  class Runner
    include Palmade::Poste::Constants

    attr_reader :options

    def initialize
      @options = { }
    end

    def run!(argv)
      parse_options.parse!(argv)

      cmd = argv.first
      unless cmd.nil?
        case cmd.to_sym
        when :start
          cmd_start
        when :stop
          cmd_stop
        when :restart
          cmd_restart
        when :diag
          cmd_diag
        when :initialize
          cmd_initialize
        when :list_spool
          cmd_list_spool
        else
          raise CmdError, "Unknown command #{cmd}"
        end
      else
        show_help
      end
    end

    protected

    def configure
      if defined?(@config)
        @config
      else
        config_file = options.include?(:config_file) ? options[:config_file] : DEFAULT_CONFIG_FILE
        @config = Config.parse(config_file)
        Palmade::Poste.config = @config
      end
    end

    def init
      if defined?(@init)
        @init
      else
        @init = Palmade::Poste.init!(@config)
      end
    end

    def cmd_diag
      configure
      init.say "== CONFIG ==\n%s\n", @config.diagnostic_dump
    end

    def cmd_start
      configure

      # TODO: Change to use puppet_master
      smtps = init.smtp_server
      smtps.configure
      smtps.start
    end

    def cmd_stop
      configure

      # Send a KILL signal to running daemon
    end

    def cmd_restart
      cmd_stop
      cmd_start
    end

    def cmd_initialize
      configure

      FileUtils.mkpath(@config.tmp_path)
      FileUtils.mkpath(@config.log_path)

      SpoolMaintainer.initialize_spool_path
    end

    def cmd_list_spool
      configure

      ent = SpoolMaintainer.find_spool_entries

      unless ent.empty?
        puts "Found %d entries" % ent.size
        ent.each do |e|
          sm = MimeMessage.create_from_spool(e.first)
          puts "  %s %s" % [ sm.transaction_id, Utils.cleanup_email(sm.sender) ]
        end
      else
        puts "Found no spool entries"
      end
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
