
require 'rpasswd/entry'

module Rpasswd
    class InvalidPasswdEntry < StandardError ; end

    # A single record in an htdigest file.  
    class PasswdEntry < Entry

        # valid encryption types
        MD5     = "md5"
        CRYPT   = "crypt"
        SHA     = "sha"
        PLAIN   = "plaintext"

        VALID_ALGORITHMS = [ MD5, CRYPT, SHA, PLAIN ]

        APR1_ID = "$apr1$" # for detection of password encryption type.
         
        attr_accessor :user
        attr_accessor :digest
        attr_accessor :algorithm

        class << self
            def from_line(line)
                parts = is_entry!(line)
                d = PasswdEntry.new(parts[0])
                d.digest = parts[1]
                d.algorithm = determine_algorithm(parts[1])
                return d
            end

            # test if a line is an entry, raise InvalidPasswdEntry if it is not.
            # an entry must be composed of 2 parts, username:encrypted_password
            # where username, and password do not contain the ':' character 
            def is_entry!(line)
                raise InvalidPasswdEntry, "line commented out" if line =~ /\A#/
                parts = line.strip.split(":")
                raise InvalidPasswdEntry, "line must be of the format username:pssword" if parts.size != 2
                return parts
            end

            # test if a line is an entry and return true or false
            def is_entry?(line)
                begin
                    is_entry!(line)
                    return true
                rescue InvalidPasswdEntry
                    return false
                end
            end
        end

        def initialize(user, password = "", algorithm = CRYPT)
            raise InvalidPasswdEntry, "`#{algorithm}' is an invalid encryption mode, use one of: #{VALID_ALGORITHMS.join(', ')}" unless VALID_ALGORITHMS.include?(algorithm)

            @user      = user
            @algorithm = algorithm
            @digest    = calc_digest(password)
        end

        def password=(new_password)
            @digest = calc_digest(new_password)
        end

        def calc_digest(password)
            p = passwod
            case algorithm
            when CRYPT
            when SHA1
            when MD5
            when PLAIN
                nil
            else
                raise InvalidPasswordEntry
            end
        end

        def authenticated?(check_password)
            d = calc_digest(check_passwd)
            return d == digest
        end

        def key
            return "#{user}"
        end

        def to_s
            "#{user}:#{digest}"
        end
    end
end
