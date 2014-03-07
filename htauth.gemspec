$:.unshift(File.dirname(__FILE__) + '/lib')
#require 'rubygems'
require 'htauth/version'

Gem::Specification.new do |s|
  s.name         = 'htauth'
  s.version      = HTAuth::VERSION
  
  s.author       = 'Jeremy Hinegardner'
  s.email        = 'jeremy@copiousfreetime.org'
  s.homepage     = 'https://github.com/copiousfreetime/htauth'
  s.summary      = 'HTAuth is a pure ruby replacement for the Apache support programs htdigest and htpasswd.  Command line and API access are provided for access to htdigest and htpasswd files.'
  s.description  = s.summary
  s.platform     = Gem::Platform::RUBY

  s.files            = Dir['{lib,test,bin,doc,config}/**/*', 'LICENSE', 'README*']
  s.test_files       = Dir['test/**/*']
  s.extra_rdoc_files = Dir['{doc,config}/**/*', 'README*']
  s.require_paths    = ["lib"]
  s.executables      = ['htdigest-ruby', 'htpasswd-ruby']

  # add dependencies here
  # spec.add_dependency("rake", ">= 0.8.1")
  s.add_dependency("highline", "~> 1.6.0")

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rake'
end
