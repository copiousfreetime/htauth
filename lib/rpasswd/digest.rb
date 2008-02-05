require 'rpasswd/digest_file'
require 'ostruct'
require 'optparse'

require 'rubygems'
require 'highline'

module Rpasswd
    class Digest

        MAX_PASSWD_LENGTH = 255

        attr_accessor :digest_file

        def initialize
            @digest_file = nil
        end

        def options
            if @options.nil? then
                @options                = ::OpenStruct.new
                @options.show_version   = false
                @options.show_help      = false
                @options.file_mode      = DigestFile::ALTER
                @options.passwdfile     = nil
                @options.realm          = nil
                @options.username       = nil
                @options.delete_entry   = false
            end
            @options
        end

        def option_parser
            if not @option_parser then
                @option_parser = OptionParser.new do |op|
                    op.banner = "Usage: #{op.program_name} [options] passwordfile realm username"
                    op.on("-c", "--create", "create a new digest password file.") do |c|
                        options.file_mode = DigestFile::CREATE
                    end

                    op.on("-d", "--delete", "delete the entry in the file") do |d|
                        options.delete_entry = d
                    end

                    op.on("-h", "--help", "display this help") do |h|
                        options.show_help = h
                    end

                    op.on("-v", "--version", "show version info") do |v|
                        options.show_version = v
                    end
                end
            end
            @option_parser
        end

        def show_help
            $stdout.puts option_parser
            exit 1
        end

        def show_version
            $stdout.puts "#{option_parser.program_name}: version #{Rpasswd::VERSION}"
            exit 1
        end

        def parse_options(argv)
            begin
                option_parser.parse!(argv)
                show_version if options.show_version
                show_help if options.show_help or argv.size < 3

                options.passwdfile = argv.shift
                options.realm      = argv.shift
                options.username   = argv.shift
            rescue ::OptionParser::ParseError => pe
                $stderr.puts "ERROR: #{option_parser.program_name} - #{pe}"
                $stderr.puts "Try `#{option_parser.program_name} --help` for more information"
                exit 1
            end
        end

        def run(argv)
            begin
                parse_options(argv)
                digest_file = DigestFile.new(options.passwdfile, options.file_mode)

                if options.delete_entry then
                    digest_file.delete(options.username, options.realm)
                else
                    # initialize here so that if $stdin is overwritten it gest picked up
                    hl = ::HighLine.new

                    action = digest_file.has_entry?(options.username, options.realm) ? "Changing" : "Adding"

                    $stdout.puts "#{action} password for #{options.username} in realm #{options.realm}."

                    pw_in       = hl.ask("        New password: ") { |q| q.echo = '*' } 
                    raise PasswordError, "password '#{pw_in}' too long" if pw_in.length >= MAX_PASSWD_LENGTH
                    
                    pw_validate = hl.ask("Re-type new password: ") { |q| q.echo = '*' }
                    raise PasswordError, "They don't match, sorry." unless pw_in == pw_validate

                    digest_file.add_or_update(options.username, options.realm, pw_in)
                end

                digest_file.save!

            rescue Rpasswd::FileAccessError => fae
                msg = "Could not open password file #{options.passwdfile} "
                $stderr.puts "#{msg}: #{fae.message}"
                $stderr.puts fae.backtrace.join("\n")
                exit 1
            rescue Rpasswd::PasswordError => pe
                $stderr.puts "#{pe.message}"
                exit 1
            rescue Rpasswd::DigestFileError => fe
                $stderr.puts "#{fe.message}"
                exit 1
            rescue SignalException => se
                $stderr.puts
                $stderr.puts "Interrupted"
                exit 1
            end
            exit 0
        end
    end
end
