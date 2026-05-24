# frozen_string_literal: true

# vim: syntax=ruby
load "tasks/this.rb"
require "date"

This.name     = "htauth"
This.author   = "Jeremy Hinegardner"
This.email    = "jeremy@copiousfreetime.org"
This.homepage = "http://github.com/copiousfreetime/#{This.name}"

This.ruby_gemspec do |spec|
  spec.date = Date.today.to_s

  spec.add_dependency("bcrypt", "~> 3.1")
  spec.add_dependency("base64", "~> 0.2")
  spec.add_dependency("ostruct", "~> 0.6")

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/copiousfreetime/htauth/issues",
    "changelog_uri" => "https://github.com/copiousfreetime/htauth/blob/master/HISTORY.md",
    "homepage_uri" => "https://github.com/copiousfreetime/htauth",
    "source_code_uri" => "https://github.com/copiousfreetime/htauth",
  }
  spec.license = "MIT"
end

load "tasks/default.rake"
