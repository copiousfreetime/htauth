require 'htauth/errors'
require 'htauth/passwd_file'

require 'ostruct'
require 'optparse'

require 'highline'

module HTAuth
  class Passwd

    MAX_PASSWD_LENGTH = 255

    attr_accessor :passwd_file

    def initialize
      @passwd_file = nil
      @option_parser = nil
      @options = nil
    end

    def options
      if @options.nil? then
        @options                = ::OpenStruct.new
        @options.batch_mode     = false
        @options.file_mode      = File::ALTER
        @options.passwdfile     = nil
        @options.algorithm      = Algorithm::EXISTING
        @options.send_to_stdout = false
        @options.show_version   = false
        @options.show_help      = false
        @options.username       = nil
        @options.delete_entry   = false
        @options.password       = ""
      end
      @options
    end

    def option_parser
      if not @option_parser then
        @option_parser = OptionParser.new do |op|
          op.banner = <<EOB
Usage: 
          #{op.program_name} [-cmdpsD] passwordfile username
          #{op.program_name} -b[cmdpsD] passwordfile username password

          #{op.program_name} -n[mdps] username
          #{op.program_name} -nb[mdps] username password
EOB

          op.separator ""

          op.on("-b", "--batch", "Batch mode, get the password from the command line, rather than prompt") do |b|
            options.batch_mode = b
          end

          op.on("-c", "--create", "Create a new file; this overwrites an existing file.") do |c|
            options.file_mode = HTAuth::File::CREATE
          end

          op.on("-d", "--crypt", "Force CRYPT encryption of the password.") do |c|
            options.algorithm = "crypt"
          end

          op.on("-D", "--delete", "Delete the specified user.") do |d|
            options.delete_entry = d
          end

          op.on("-h", "--help", "Display this help.") do |h|
            options.show_help = h
          end

          op.on("-m", "--md5", "Force MD5 encryption of the password (default).") do |m|
            options.algorithm = "md5"
          end

          op.on("-n", "--stdout", "Do not update the file; Display the results on stdout instead.") do |n|
            options.send_to_stdout = true
            options.passwdfile     = HTAuth::File::STDOUT_FLAG
          end

          op.on("-p", "--plaintext", "Do not encrypt the password (plaintext).") do |p|
            options.algorithm = "plaintext"
          end

          op.on("-s", "--sha1", "Force SHA encryption of the password.") do |s|
            options.algorithm = "sha1"
          end

          op.on("-v", "--version", "Show version info.") do |v|
            options.show_version = v
          end

          op.separator ""

          op.separator "The SHA algorihtm does not use a salt and is less secure than the MD5 algorithm"
        end
      end
      @option_parser
    end

    def show_help
      $stdout.puts option_parser
      exit 1
    end

    def show_version
      $stdout.puts "#{option_parser.program_name}: version #{HTAuth::VERSION}"
      exit 1
    end

    def parse_options(argv)
      begin
        option_parser.parse!(argv)
        show_version if options.show_version
        show_help if options.show_help 

        raise ::OptionParser::ParseError, "Unable to send to stdout AND create a new file" if options.send_to_stdout and (options.file_mode == File::CREATE)
        raise ::OptionParser::ParseError, "a username is needed" if options.send_to_stdout and argv.size < 1
        raise ::OptionParser::ParseError, "a username and password are needed" if options.send_to_stdout and options.batch_mode  and ( argv.size < 2 ) 
        raise ::OptionParser::ParseError, "a passwordfile, username and password are needed " if not options.send_to_stdout and options.batch_mode and ( argv.size < 3 )
        raise ::OptionParser::ParseError, "a passwordfile and username are needed" if argv.size < 2

        options.passwdfile = argv.shift unless options.send_to_stdout
        options.username   = argv.shift
        options.password   = argv.shift if options.batch_mode

      rescue ::OptionParser::ParseError => pe
        $stderr.puts "ERROR: #{option_parser.program_name} - #{pe}"
        show_help
        exit 1
      end
    end

    def run(argv, env = ENV)
      begin
        parse_options(argv)
        passwd_file = PasswdFile.new(options.passwdfile, options.file_mode)

        if options.delete_entry then
          passwd_file.delete(options.username)
        else
          unless options.batch_mode 
            # initialize here so that if $stdin is overwritten it gest picked up
            hl = ::HighLine.new

            action = passwd_file.has_entry?(options.username) ? "Changing" : "Adding"

            $stdout.puts "#{action} password for #{options.username}."

            pw_in       = hl.ask("        New password: ") { |q| q.echo = '*' } 
            raise PasswordError, "password '#{pw_in}' too long" if pw_in.length >= MAX_PASSWD_LENGTH

            pw_validate = hl.ask("Re-type new password: ") { |q| q.echo = '*' }
            raise PasswordError, "They don't match, sorry." unless pw_in == pw_validate
            options.password = pw_in
          end
          passwd_file.add_or_update(options.username, options.password, options.algorithm)
        end

        passwd_file.save! 

      rescue HTAuth::FileAccessError => fae
        msg = "Password file failure (#{options.passwdfile}) "
        $stderr.puts "#{msg}: #{fae.message}"
        exit 1
      rescue HTAuth::PasswordError => pe
        $stderr.puts "#{pe.message}"
        exit 1
      rescue HTAuth::PasswdFileError => fe
        $stderr.puts "#{fe.message}"
        exit 1
      rescue SignalException => se
        $stderr.puts
        $stderr.puts "Interrupted #{se}"
        exit 1
      end
      exit 0
    end
  end
end
