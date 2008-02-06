require 'rubygems'
require 'rpasswd/specification'
require 'rpasswd/version'
require 'rake'

# The Gem Specification plus some extras for rpasswd.
module HTAuth
    SPEC = HTAuth::Specification.new do |spec|
                spec.name               = "htauth"
                spec.version            = HTAuth::VERSION
                spec.rubyforge_project  = "copiousfreetime"
                spec.author             = "Jeremy Hinegardner"
                spec.email              = "jeremy@hinegardner.org"
                spec.homepage           = "http://copiousfreetime.rubyforge.org/htauth"

                spec.summary            = "A Summary of rpasswd."
                spec.description        = <<-DESC
                A longer more detailed description of rpasswd.
                DESC

                spec.extra_rdoc_files   = FileList["[A-Z]*"]
                spec.has_rdoc           = true
                spec.rdoc_main          = "README"
                spec.rdoc_options       = [ "--line-numbers" , "--inline-source" ]

                spec.test_files         = FileList["spec/**/*"]
                spec.files              = spec.test_files + spec.extra_rdoc_files + 
                                          FileList["lib/**/*.rb"]
                
                spec.platform           = Gem::Platform::RUBY

                spec.local_rdoc_dir     = "doc/rdoc"
                spec.remote_rdoc_dir    = "#{spec.name}/rdoc"
                spec.local_coverage_dir = "doc/coverage"
                spec.remote_coverage_dir= "#{spec.name}/coverage"

                spec.remote_site_dir    = "#{spec.name}/"

           end
end


