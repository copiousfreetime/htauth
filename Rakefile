# vim: syntax=ruby
load 'tasks/this.rb'

This.name     = "htauth"
This.author   = "Jeremy Hinegardner"
This.email    = "jeremy@copiousfreetime.org"
This.homepage = "http://github.com/copiousfreetime/#{ This.name }"

This.ruby_gemspec do |spec|
  spec.add_dependency( 'bcrypt', '~> 3.1' )

  spec.add_development_dependency( 'rake'     , '~> 13.0')
  spec.add_development_dependency( 'minitest' , '~> 5.5' )
  spec.add_development_dependency( 'rdoc'     , '~> 6.2' )
  spec.add_development_dependency( 'simplecov', '~> 0.17' )

  spec.license = "MIT"
end

load 'tasks/default.rake'
