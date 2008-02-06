require 'rubygems'
require 'htauth/specification'
require 'htauth/version'
require 'rake'

# The Gem Specification plus some extras for htauth.
module HTAuth
    SPEC = HTAuth::Specification.new do |spec|
                spec.name               = "htauth"
                spec.version            = HTAuth::VERSION
                spec.rubyforge_project  = "copiousfreetime"
                spec.author             = "Jeremy Hinegardner"
                spec.email              = "jeremy@hinegardner.org"
                spec.homepage           = "http://copiousfreetime.rubyforge.org/htauth"

                spec.summary            = "HTAuth provides htdigest and htpasswd support."
                spec.description        = <<-DESC
                HTAuth is a pure ruby replacement for the Apache support programs htdigest
                and htpasswd.  Command line and API access are provided for access to
                htdigest and htpasswd files.
                DESC

                spec.extra_rdoc_files   = FileList["CHANGES", "LICENSE", "README"]
                spec.has_rdoc           = true
                spec.rdoc_main          = "README"
                spec.rdoc_options       = [ "--line-numbers" , "--inline-source" ]

                spec.test_files         = FileList["spec/**/*"]
                spec.executables        << "htdigest-ruby" 
                spec.executables        << "htpasswd-ruby" 
                spec.files              = spec.test_files + spec.extra_rdoc_files + 
                                          FileList["lib/**/*.rb"]
               
                spec.add_dependency("highline", ">= 1.4.0")

                spec.platform           = Gem::Platform::RUBY

                spec.remote_user        = "jjh"
                spec.local_rdoc_dir     = "doc/rdoc"
                spec.remote_rdoc_dir    = ""
                spec.local_coverage_dir = "doc/coverage"

                spec.remote_site_dir    = "#{spec.name}/"

                spec.post_install_message = <<EOM
Try out 'htpasswd-ruby' or 'htdigest-ruby' to get started.
EOM

           end
end


