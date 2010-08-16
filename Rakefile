require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "fcsh"
    gem.summary = %Q{Wrapper for flex fcsh command}
    gem.description = %Q{}
    gem.email = "jaapvandermeer@gmail.com"
    gem.homepage = "http://github.com/japetheape/fcsh"
    gem.authors = ["Jaap van der Meer"]
    gem.add_development_dependency "rspec", ">= 2"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end




require "rspec/core/rake_task"
require "rspec/core/version"


RSpec::Core::RakeTask.new(:spec)

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "fcsh #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
