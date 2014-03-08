require 'htauth/errors'
require 'htauth/entry'
require 'htauth/algorithm'

module HTAuth
  class InvalidPasswdEntry < StandardError ; end

  # A single record in an htdigest file.  
  class PasswdEntry < Entry

    attr_accessor :user
    attr_accessor :digest
    attr_reader   :algorithm

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

    def initialize(user, password = "", alg = Algorithm::DEFAULT, alg_params = {} ) 
      @user      = user
      alg = Algorithm::DEFAULT if alg == Algorithm::EXISTING 
      @algorithm = Algorithm.algorithm_from_name(alg, alg_params)
      @digest    = algorithm.encode(password)
    end

    def algorithm=(alg)
      if alg.kind_of?(Array) then
        if alg.size == 1 then
          @algorithm = alg.first
        else
          @algorithm = alg
        end
      else
        @algorithm = Algorithm.algorithm_from_name(alg) unless Algorithm::EXISTING == alg
      end
      return @algorithm
    end

    def password=(new_password)
      if algorithm.kind_of?(Array) then
        @algorithm = Algorithm.algorithm_from_name("crypt")
      end
      @digest = algorithm.encode(new_password)
    end

    # check the password and make sure it works, in the case that the algorithm is unknown it
    # tries all of the ones that it thinks it could be, and marks the algorithm if it matches
    def authenticated?(check_password)
      authed = false
      if algorithm.kind_of?(Array) then
        algorithm.each do |alg|
          if alg.encode(check_password) == digest then
            @algorithm = alg
            authed = true
            break
          end
        end
      else
        authed = digest == algorithm.encode(check_password)
      end
      return authed
    end

    def key
      return "#{user}"
    end

    def to_s
      "#{user}:#{digest}"
    end
  end
end
