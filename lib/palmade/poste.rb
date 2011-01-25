require 'logger'
require 'benchmark'

POSTE_LIB_DIR = File.expand_path(File.dirname(__FILE__))

module Palmade
  module Poste
    autoload :Constants, File.join(POSTE_LIB_DIR, 'poste/constants')
    autoload :Init, File.join(POSTE_LIB_DIR, 'poste/init')
    autoload :Config, File.join(POSTE_LIB_DIR, 'poste/config')

    class PosteError < StandardError; end
    class ConfigError < PosteError; end

    def self.init; @@init; end
    def self.init=(i); @@init = i; end
  end
end
