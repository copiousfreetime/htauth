if HAVE_RUBYFORGE then
    require 'rubyforge'
    
    #-----------------------------------------------------------------------
    # Rubyforge additions to the task library
    #-----------------------------------------------------------------------
    namespace :dist do
        desc "Release files to rubyforge"
        task :rubyforge => [:clean, :package] do

            rubyforge = RubyForge.new

            # make sure this release doesn't already exist
            releases = rubyforge.autoconfig['release_ids']
            if releases.has_key?(HTAuth::SPEC.name) and releases[HTAuth::SPEC.name][HTAuth::VERSION] then
                abort("Release #{HTAuth::VERSION} already exists! Unable to release.")
            end

            config = rubyforge.userconfig
            config["release_notes"]     = HTAuth::SPEC.description
            config["release_changes"]   = last_changeset
            config["Prefomatted"]       = true

            puts "Uploading to rubyforge..."
            files = FileList[File.join("pkg","#{HTAuth::SPEC.name}-#{HTAuth::VERSION}*.*")].to_a
            rubyforge.login
            rubyforge.add_release(HTAuth::SPEC.rubyforge_project, HTAuth::SPEC.name, HTAuth::VERSION, *files)
            puts "done."
            end
    end

    namespace :announce do
        desc "Post news of #{HTAuth::SPEC.name} to #{HTAuth::SPEC.rubyforge_project} on rubyforge"
        task :rubyforge do
            subject, title, body, urls = announcement
            rubyforge = RubyForge.new
            rubyforge.login
            rubyforge.post_news(HTAuth::SPEC.rubyforge_project, subject, "#{title}\n\n#{urls}\n\n#{body}")
            puts "Posted to rubyforge"
        end

    end
end
