#-----------------------------------------------------------------------
# Distribution and Packaging
#-----------------------------------------------------------------------
namespace :dist do

    GEM_SPEC = eval(Rpasswd::SPEC.to_ruby)

    Rake::GemPackageTask.new(GEM_SPEC) do |pkg|
        pkg.need_tar = Rpasswd::SPEC.need_tar
        pkg.need_zip = Rpasswd::SPEC.need_zip
    end

    desc "Install as a gem"
    task :install => [:clobber, :package] do
        sh "sudo gem install pkg/#{Rpasswd::SPEC.full_name}.gem"
    end

    # uninstall the gem and all executables
    desc "Uninstall gem"
    task :uninstall do 
        sh "sudo gem uninstall #{Rpasswd::SPEC.name} -x"
    end

    desc "dump gemspec"
    task :gemspec do
        puts Rpasswd::SPEC.to_ruby
    end

    desc "reinstall gem"
    task :reinstall => [:uninstall, :install]

end