# vim: syntax=ruby
load 'tasks/this.rb'

This.name     = "htauth"
This.author   = "Jeremy Hinegardner"
This.email    = "jeremy@copiousfreetime.org"
This.homepage = "http://github.com/copiousfreetime/#{ This.name }"

This.ruby_gemspec do |spec|
  spec.add_dependency( 'bcrypt', '~> 3.1' )
  spec.add_dependency( 'base64', '~> 0.2' )

  spec.add_development_dependency( 'argon2'   , '~> 2.3')
  spec.add_development_dependency( 'debug'    , '~> 1.9')
  spec.add_development_dependency( 'rake'     , '~> 13.1')
  spec.add_development_dependency( 'minitest' , '~> 5.21' )
  spec.add_development_dependency( 'minitest-junit' , '~> 1.1' )
  spec.add_development_dependency( 'rdoc'     , '~> 6.6' )
  spec.add_development_dependency( 'simplecov', '~> 0.21' )

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/copiousfreetime/htauth/issues",
    "changelog_uri"   => "https://github.com/copiousfreetime/htauth/blob/master/HISTORY.md",
    "homepage_uri"    => "https://github.com/copiousfreetime/htauth",
    "source_code_uri" => "https://github.com/copiousfreetime/htauth",
  }
  spec.license = "MIT"
end

load 'tasks/default.rake'
