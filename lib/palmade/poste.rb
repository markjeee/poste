require 'pp'
require 'logger'
require 'benchmark'

POSTE_LIB_DIR = File.expand_path(File.dirname(__FILE__))

module Palmade
  module Poste
    autoload :Constants, File.join(POSTE_LIB_DIR, 'poste/constants')
    autoload :Init, File.join(POSTE_LIB_DIR, 'poste/init')
    autoload :Config, File.join(POSTE_LIB_DIR, 'poste/config')
    autoload :Runner, File.join(POSTE_LIB_DIR, 'poste/runner')
    autoload :Utils, File.join(POSTE_LIB_DIR, 'poste/utils')

    autoload :SmtpServer, File.join(POSTE_LIB_DIR, 'poste/smtp_server')
    autoload :SmtpClientConnection, File.join(POSTE_LIB_DIR, 'poste/smtp_client_connection')
    autoload :SmtpMessage, File.join(POSTE_LIB_DIR, 'poste/smtp_message')

    autoload :SpoolMaintainer, File.join(POSTE_LIB_DIR, 'poste/spool_maintainer')

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
