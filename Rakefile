# vim: syntax=ruby
require 'rubygems'
require 'bundler/setup'

require File.expand_path('../lib/htauth/version', __FILE__)

# task: build install release
require 'bundler/gem_tasks'

# task: clean clobber
require 'rake/clean'
# .rbc files from ruby 2.0
CLOBBER << FileList['**/*.rbc']

# task: test
require 'rake/testtask'
Rake::TestTask.new(:test) do |t|
  t.ruby_opts    = %w(-w -rubygems)
  t.libs         = %w(lib spec test)
  t.pattern      = '{test,spec}/**/{test_*,*_spec}.rb'
end

desc 'Run tests with code coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task[:test].execute
end
CLOBBER << FileList['coverage']

# task: rdoc clobber_rdoc rerdoc
gem 'rdoc'
require 'rdoc/task'
RDoc::Task.new do |t|
  t.markup   = 'tomdoc'
  t.rdoc_dir = 'doc'
  t.main     = 'README.md'
  t.title    = "HTAuth #{HTAuth::Version}"
  t.rdoc_files.include(FileList['*.{rdoc,md,txt}'], FileList['lib/**/*.rb'])
end

# task: (default)
task default: :test
