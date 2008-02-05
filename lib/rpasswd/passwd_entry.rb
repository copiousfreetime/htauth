
require 'rpasswd/entry'

module Rpasswd
    class InvalidPasswdEntry < StandardError ; end

    # A single record in an htdigest file.  
    class PasswdEntry < Entry

        attr_accessor :user
        attr_accessor :digest
        attr_accessor :algorithm

        class << self
            def from_line(line)
                parts = is_entry!(line)
                d = PasswdEntry.new(parts[0])
                d.digest = parts[1]
                d.algorithm = Algorithm.algorithms_from_field(parts[1])
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

        def initialize(user, password = "",alg = 'crypt', alg_params = {} ) 
            @user      = user
            @algorithm = Algorithm.algorithm_from_name(alg, alg_params)
            @digest    = algorithm.encode(password)
        end

        def password=(new_password)
            @digest = algorithm.encode(new_password)
        end

        def authenticated?(check_password)
            d = algorithm.encode(check_password)
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
