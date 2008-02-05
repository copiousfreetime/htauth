#-----------------------------------------------------------------------
# Documentation
#-----------------------------------------------------------------------

namespace :doc do
    
    # generating documentation locally
    Rake::RDocTask.new do |rdoc|
        rdoc.rdoc_dir   = Rpasswd::SPEC.local_rdoc_dir
        rdoc.options    = Rpasswd::SPEC.rdoc_options 
        rdoc.rdoc_files = Rpasswd::SPEC.rdoc_files
    end

    desc "Deploy the RDoc documentation to #{Rpasswd::SPEC.remote_rdoc_location}"
    task :deploy => :rerdoc do
        sh "rsync -zav --delete #{Rpasswd::SPEC.local_rdoc_dir}/ #{Rpasswd::SPEC.remote_rdoc_location}"
    end

    if HAVE_HEEL then
        desc "View the RDoc documentation locally"
        task :view => :rdoc do
            sh "heel --root  #{Rpasswd::SPEC.local_rdoc_dir}"
        end
    end
end