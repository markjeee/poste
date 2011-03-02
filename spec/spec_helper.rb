require 'rubygems'
gem 'rspec', '>= 2.5.0'

require File.expand_path(File.join(File.dirname(__FILE__), '../lib/palmade/poste'))

if ENV.include?('ENABLE_MAIL')
  ENABLE_MAIL = true

  gem 'mail'
  require 'mail'
else
  ENABLE_MAIL = false
end

SPEC_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
SPEC_ENV = "test"

SPEC_POSTE_CONFIG_FILE = File.join(SPEC_ROOT, 'spec/config/poste.yml')

require 'rspec'
RSpec.configure do |c|
  unless ENABLE_MAIL
    c.filter_run_excluding(:mail => true)
  end
end
