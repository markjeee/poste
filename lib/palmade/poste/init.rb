module Palmade::Poste
  class Init
    attr_reader :logger
    attr_reader :config

    def self.init(config)
      new(config).init
    end

    def initialize(config)
      @config = config
    end

    def init
      self
    end

    def say(msg, *args)
      $stderr.puts(sprintf(msg, *args))
    end

    def smtp_server
      SmtpServer.new(self)
    end

    # Create the global puppet_master, to invoke and monitor
    # the other puppets and instances.
    #
    # :TODO:
    #
    def puppet_master

    end
  end
end
