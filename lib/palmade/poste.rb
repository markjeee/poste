require 'pp'
require 'logger'
require 'benchmark'
require 'time'
require 'date'

POSTE_LIB_DIR = File.expand_path('..', __FILE__)
POSTE_ROOT_DIR = File.expand_path('../../../', __FILE__)

# This a hack for now, to load palmade puppet master. Later on
# puppet master can be loaded using Gem.
require File.expand_path('../puppet_master/lib/palmade/puppet_master', POSTE_ROOT_DIR)
require File.expand_path('../rediscule/lib/palmade/rediscule', POSTE_ROOT_DIR)

module Palmade
  module Poste
    autoload :Constants, File.join(POSTE_LIB_DIR, 'poste/constants')
    autoload :Init, File.join(POSTE_LIB_DIR, 'poste/init')
    autoload :Config, File.join(POSTE_LIB_DIR, 'poste/config')
    autoload :Utils, File.join(POSTE_LIB_DIR, 'poste/utils')

    # Command line interface
    autoload :Runner, File.join(POSTE_LIB_DIR, 'poste/runner')

    # SMTP protocol support
    autoload :SmtpPuppet, File.join(POSTE_LIB_DIR, 'poste/smtp_puppet')
    autoload :SmtpServer, File.join(POSTE_LIB_DIR, 'poste/smtp_server')
    autoload :SmtpClientConnection, File.join(POSTE_LIB_DIR, 'poste/smtp_client_connection')

    # A generic representation of a MIME message, transferred primarily via SMTP.
    autoload :MimeMessage, File.join(POSTE_LIB_DIR, 'poste/mime_message')

    # For maintaining the spool directory
    autoload :SpoolMaintainer, File.join(POSTE_LIB_DIR, 'poste/spool_maintainer')
    autoload :MongoMaintainer, File.join(POSTE_LIB_DIR, 'poste/mongo_maintainer')

    # For Poste maintainance tasks
    autoload :LinemanPuppet, File.join(POSTE_LIB_DIR, 'poste/lineman_puppet')

    # For Rediscule Jobjob workers
    autoload :Workers, File.join(POSTE_LIB_DIR, 'poste/workers')

    # For the web interface and web service API (uses Thin, Rack and Sinatra)
    autoload :WebPuppet, File.join(POSTE_LIB_DIR, 'poste/web_puppet')

    class PosteError < StandardError; end
    class ConfigError < PosteError; end
    class CmdError < PosteError; end
    class PortInUseError < PosteError; end

    def self.config; @@config; end
    def self.config=(c); @@config = c; end

    def self.init; @@init; end
    def self.init=(i); @@init = i; end

    def self.init!(config)
      self.config = config
      self.init = Init.init(config)
    end

    def self.run!(argv)
      Runner.new.run!(argv)
    end
  end
end
