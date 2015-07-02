require File.expand_path('../lib/htauth/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'htauth'
  s.version = HTAuth::Version.to_s
  s.authors = ['Jeremy Hinegardner']
  s.email = 'jeremy@copiousfreetime.org'
  s.description = 'HTAuth is a pure ruby replacement for the Apache support programs htdigest and htpasswd.  Command line and API access are provided for access to htdigest and htpasswd files.'
  s.summary = 'HTAuth is a pure ruby replacement for the Apache support programs htdigest and htpasswd.'
  s.homepage = 'https://github.com/copiousfreetime/htauth'
  s.license = 'ISC'

  s.required_ruby_version = '>= 1.9.3'
  s.files = `git ls-files`.split($\)
  s.executables = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.rdoc_options = ['--main', 'README.md', '--markup', 'tomdoc']
  s.extra_rdoc_files = ['CONTRIBUTING.md', 'HISTORY.md', 'README.md']

  s.add_runtime_dependency 'highline', '~> 1.6'
  s.add_development_dependency 'bundler'
end
