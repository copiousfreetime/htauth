#-----------------------------------------------------------------------
# Announcement tasks
#   - create a basic email template that can be used to send email to
#     rubytalk.
#-----------------------------------------------------------------------
def changes
    change_file = File.expand_path(File.join(HTAuth::ROOT_DIR,"CHANGES"))
    sections    = File.read(change_file).split(/^(?=== )/)
end

def last_changeset
    changes[1]
end

def announcement
    puts changes.size
    urls    = "  #{HTAuth::SPEC.homepage}"
    subject = "#{HTAuth::SPEC.name} #{HTAuth::VERSION} Released"
    title   = "#{HTAuth::SPEC.name} version #{HTAuth::VERSION} has been released."
    body    = <<BODY
#{HTAuth::SPEC.description.rstrip}

{{ Changelog for Version #{HTAuth::VERSION} }}

#{last_changeset.rstrip}

BODY

    return subject, title, body, urls
end

namespace :announce do
    desc "create email for ruby-talk"
    task :email do
        subject, title, body, urls = announcement

        File.open("email.txt", "w") do |mail|
            mail.puts "From: #{HTAuth::SPEC.author} <#{HTAuth::SPEC.email}>"
            mail.puts "To: ruby-talk@ruby-lang.org"
            mail.puts "Date: #{Time.now.rfc2822}"
            mail.puts "Subject: [ANN] #{subject}"
            mail.puts
            mail.puts title
            mail.puts
            mail.puts urls
            mail.puts 
            mail.puts body
            mail.puts 
            mail.puts urls
        end
        puts "Created the following as email.txt:"
        puts "-" * 72
        puts File.read("email.txt")
        puts "-" * 72
    end
    
    CLOBBER << "email.txt"
end
