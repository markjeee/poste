require 'eventmachine'

module Palmade::Poste
  class SmtpServer
    DEFAULT_SMTP_PORT = 25

    attr_reader :init
    attr_reader :logger
    attr_reader :config

    attr_reader :listen

    def running?; @running; end
    def running!; @running = true; end

    def initialize(init)
      @init = init
      @logger = init.logger
      @config = init.config

      @running = false

      @listen = [ ]
    end

    CIpPortFormatRegex = /\A\d{1,3}\.\d{1,3}\.\d{1,3}.\d{1,3}(\:\d+)?\Z/i.freeze
    def configure
      if @config.include?(:smtp)
        smtp_config = @config[:smtp]

        case smtp_config[:listen]
        when String
          @listen.push(smtp_config[:listen])
        when Array
          @listen += smtp_config[:listen]
        else
          raise ConfigError, "Unsupported type for smtp config :listen"
        end

        # check if we provided proper data for listen
        @listen.each do |l|
          unless l =~ CIpPortFormatRegex
            raise ConfigError, "Listen parameter is wrong format: #{l}"
          end
        end
      else
        raise ConfigError, "Config file missing configuration for SMTP"
      end

      self
    end

    def start
      register_signals!
      em_run
    end

    def stop
      if running?
        EventMachine.stop_event_loop if EventMachine.reactor_running?
        @running = false
      end
    end

    protected

    def register_signals!
      [ :INT ].each { |sig| trap(sig) { stop } } # do nothing
      [ :QUIT ].each { |sig| trap(sig) { stop } } # graceful shutdown
      [ :TERM, :KILL ].each { |sig| trap(sig) { exit!(0) } } # instant #shutdown
    end

    def em_run
      running!

      EventMachine.run do
        EventMachine.epoll rescue nil
        EventMachine.kqueue rescue nil

        # do something, aight?
        start_servers
      end
    end

    def start_servers
      @listen.each do |l|
        ip, port = l.split(/\:/, 2)
        if port.nil?
          port = DEFAULT_SMTP_PORT
        else
          port = port.to_i
        end

        if Utils.is_port_open?(ip, port)
          raise PortInUseError, "Port already in use! #{ip}:#{port}"
        end

        init.say "Listening to: %s:%d", ip, port
        EventMachine.start_server(ip, port, Palmade::Poste::SmtpClientConnection)
      end
    end
  end
end
