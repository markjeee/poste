require 'rubygems'
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

gem 'rspec'
require 'spec/rake/spectask'

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files   = [ 'lib/**/*.rb' ]
end
