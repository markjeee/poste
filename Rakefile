require 'rubygems'
gem 'rspec', '>= 2.5.0'
gem 'echoe'
gem 'yard'
gem 'echoe'

require 'echoe'
Echoe.new("poste") do |p|
  p.author = "palmade"
  p.project = "palmade"
  p.summary = "Mail queue manager"

  p.dependencies = [ ]

  p.need_tar_gz = false
  p.need_tgz = true

  p.clean_pattern += [ "pkg", "lib/*.bundle", "*.gem", ".config" ]
  p.rdoc_pattern = [ 'README', 'LICENSE', 'COPYING', 'lib/**/*.rb', 'doc/**/*.rdoc' ]
end

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files   = [ 'lib/**/*.rb' ]
end

require 'rspec/core/rake_task'
desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  # Put spec opts in a file named .rspec in root
end

task :default => :spec

task :test_reset do
  `rm -Rf spec/var`
  `bin/poste -c spec/config/poste.yml initialize`
end
