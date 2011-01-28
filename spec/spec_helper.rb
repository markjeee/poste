require 'rubygems'
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/palmade/poste'))

gem 'mail'
require 'mail'

SPEC_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
SPEC_ENV = "test"

SPEC_POSTE_CONFIG_FILE = File.join(SPEC_ROOT, 'spec/config/poste.yml')
