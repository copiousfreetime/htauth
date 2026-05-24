# frozen_string_literal: true

require "htauth/cli"

require "ostruct"
require "optparse"

module HTAuth
  module CLI
    # Internal: Implemenation of the commandline htpasswd-ruby
    class Passwd
      MAX_PASSWD_LENGTH = 255

      attr_accessor :passwd_file

      def initialize
        @passwd_file = nil
        @option_parser = nil
        @options = nil
      end

      def options
        if @options.nil?
          @options                = ::OpenStruct.new
          @options.batch_mode     = false
          @options.file_mode      = File::ALTER
          @options.passwdfile     = nil
          @options.algorithm      = Algorithm::EXISTING
          @options.algorithm_args = {}
          @options.read_stdin_once = false
          @options.send_to_stdout = false
          @options.show_version   = false
          @options.show_help      = false
          @options.username       = nil
          @options.password       = ""
          @options.operation      = []
        end
        @options
      end

      def option_parser
        @option_parser ||= OptionParser.new(nil, 16) do |op|
          op.banner = <<~BANNER
            Usage:
                    #{op.program_name} [-acimBdpsD] [--verify] [-C cost] passwordfile username
                    #{op.program_name} -b[acmBdpsD] [--verify] [-C cost] passwordfile username password

                    #{op.program_name} -n[imBdps] [-C cost] username
                    #{op.program_name} -nb[mBdps] [-C cost] username password
          BANNER

          op.separator ""

          op.on("--argon2", "Force argon2 encryption of the password.") do |_a|
            options.algorithm = Algorithm::ARGON2
          end

          op.on("-b", "--batch", "Batch mode, get the password from the command line, rather than prompt.") do |b|
            options.batch_mode = b
          end

          op.on("-B", "--bcrypt", "Force bcrypt encryption of the password.") do |_b|
            options.algorithm = Algorithm::BCRYPT
          end

          op.on("-CCOST", "--cost COST", "Set the computing time used for the bcrypt algorithm",
                "(higher is more secure but slower, default: 5, valid: 4 to 31).") do |c|
            unless /\A\d+\z/.match?(c)
              raise ::OptionParser::ParseError, "the bcrypt cost must be an integer from 4 to 31, `#{c}` is invalid"
            end

            cost = c.to_i
            unless (4..31).cover?(cost)
              raise ::OptionParser::ParseError, "the bcrypt cost must be an integer from 4 to 31, `#{c}` is invalid"
            end

            options.algorithm_args = { cost: cost }
          end

          op.on("-c", "--create", "Create a new file; this overwrites an existing file.") do |_c|
            options.file_mode = HTAuth::File::CREATE
            options.operation << :add_or_update
          end

          op.on("-d", "--crypt", "Force CRYPT encryption of the password.") do |_c|
            options.algorithm = Algorithm::CRYPT
          end

          op.on("-D", "--delete", "Delete the specified user.") do |_d|
            options.operation << :delete
          end

          op.on("-h", "--help", "Display this help.") do |h|
            options.show_help = h
          end

          op.on("-i", "--stdin", "Read the passwod from stdin without verivication (for script usage).") do |_i|
            options.read_stdin_once = true
          end

          op.on("-m", "--md5", "Force MD5 encryption of the password (default).") do |_m|
            options.algorithm = Algorithm::MD5
          end

          op.on("-n", "--stdout", "Do not update the file; Display the results on stdout instead.") do |_n|
            options.send_to_stdout = true
            options.passwdfile     = HTAuth::File::STDOUT_FLAG
            options.operation     << :stdout
          end

          op.on("-p", "--plaintext", "Do not encrypt the password (plaintext).") do |_p|
            options.algorithm = Algorithm::PLAINTEXT
          end

          op.on("-s", "--sha1", "Force SHA encryption of the password.") do |_s|
            options.algorithm = Algorithm::SHA1
          end

          op.on("-v", "--version", "Show version info.") do |v|
            options.show_version = v
          end

          op.on("--verify", "Verify password for the specified user.") do |_v|
            options.operation << :verify
          end

          op.separator ""

          op.separator "The SHA algorihtm does not use a salt and is less secure than the MD5 algorithm."
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
        option_parser.parse!(argv)
        show_version if options.show_version
        show_help if options.show_help

        if options.operation.size > 1
          raise ::OptionParser::ParseError,
                "only one of --create, --stdout, --verify, --delete may be specified"
        end
        if options.send_to_stdout && (options.file_mode == File::CREATE)
          raise ::OptionParser::ParseError,
                "Unable to send to stdout AND create a new file"
        end
        raise ::OptionParser::ParseError, "a username is needed" if options.send_to_stdout && argv.empty?
        if options.send_to_stdout && options.batch_mode && (argv.size < 2)
          raise ::OptionParser::ParseError,
                "a username and password are needed"
        end
        if !options.send_to_stdout && options.batch_mode && (argv.size < 3)
          raise ::OptionParser::ParseError,
                "a passwordfile, username and password are needed "
        end
        raise ::OptionParser::ParseError, "a passwordfile and username are needed" if argv.size < 2
        if options.batch_mode && options.read_stdin_once
          raise ::OptionParser::ParseError,
                "options -i and -b are mutually exclusive"
        end

        options.operation  = options.operation.shift || :add_or_update
        options.passwdfile = argv.shift unless options.send_to_stdout
        options.username   = argv.shift
        options.password   = argv.shift if options.batch_mode
      rescue ::OptionParser::ParseError => e
        warn "ERROR: #{option_parser.program_name} - #{e}"
        show_help
        exit 1
      end

      def fetch_password(width = 20)
        return options.password if options.batch_mode

        console = Console.new
        if options.read_stdin_once
          pw_in = console.read_answer
          return pw_in
        end

        case options.operation
        when :verify
          pw_in = console.ask("Enter password: ".rjust(width))
          raise PasswordError, "password '#{pw_in}' too long" if pw_in.length >= MAX_PASSWD_LENGTH
        when :add_or_update
          pw_in = console.ask("New password: ".rjust(width))
          raise PasswordError, "password '#{pw_in}' too long" if pw_in.length >= MAX_PASSWD_LENGTH

          pw_validate = console.ask("Re-type new password: ".rjust(width))
          raise PasswordError, "They don't match, sorry." unless pw_in == pw_validate
        end

        pw_in
      end

      def run(argv, _env = ENV)
        begin
          parse_options(argv)
          console = Console.new
          passwd_file = PasswdFile.new(options.passwdfile, options.file_mode)
          case options.operation
          when :delete
            passwd_file.delete(options.username)
            passwd_file.save!
          when :verify
            raise HTAuth::Error, "User #{options.username} not found" unless passwd_file.has_entry?(options.username)

            pw_in = fetch_password
            unless passwd_file.authenticated?(options.username, pw_in)
              raise HTAuth::Error, "Password verification for user #{options.username} failed."
            end

            warn "Password for user #{options.username} correct."

          when :add_or_update
            options.password = fetch_password
            action = passwd_file.has_entry?(options.username) ? "Changing" : "Adding"
            console.say "#{action} password for #{options.username}."
            passwd_file.add_or_update(options.username, options.password, options.algorithm, options.algorithm_args)
            passwd_file.save!
          when :stdout
            options.password = fetch_password
            passwd_file.add_or_update(options.username, options.password, options.algorithm, options.algorithm_args)
            passwd_file.save!
          end
        rescue HTAuth::FileAccessError => e
          msg = "Password file failure (#{options.passwdfile}) "
          warn "#{msg}: #{e.message}"
          exit 1
        rescue HTAuth::Error => e
          warn e.message
          exit 1
        rescue SignalException => e
          $stderr.puts
          warn "Interrupted #{e}"
          exit 1
        end
        exit 0
      end
    end
  end
end
