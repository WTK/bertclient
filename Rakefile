require 'rubygems'
require 'rake'
require 'yaml'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "bertclient"
    gem.summary = %Q{BERT::Client is a threadsafe BERT-RPC client with support for persistent connections and SSL}
    gem.email = "marcin.wtorkowski@gmail.com"
    gem.homepage = "http://github.com/wtk/bertclient"
    gem.authors = ["Marcin Wtorkowski"]
    gem.add_dependency('bert')
    # gem is a Gem::Specification...
    # see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

task :default => :version

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "bertclient #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/*.rb')
end

task :console do
  exec('irb -I lib -r bertclient')
end