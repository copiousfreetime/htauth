require 'htauth/error'
require 'htauth/entry'
require 'htauth/algorithm'

module HTAuth
  # Internal: Object version of a single entry from a htpasswd file
  class PasswdEntry < Entry

    # Internal: the user of this entry
    attr_accessor :user
    # Internal: the password digest of this entry
    attr_accessor :digest
    # Internal: the algorithm used to create the digest of this entry
    attr_reader   :algorithm

    class << self
      # Internal: Create an instance of this class from a line of text
      #
      # line - a line of text from a htpasswd file
      #
      # Returns an instance of PasswdEntry
      def from_line(line)
        parts = is_entry!(line)
        d = PasswdEntry.new(parts[0])
        d.digest = parts[1]
        d.algorithm = Algorithm.algorithm_from_field(parts[1])
        return d
      end

      # Internal: test if the given line is valid for this Entry class
      #
      # A valid entry is a single line composed of two parts; a username and a
      # password separated by a ':' character. Neither the username nor the
      # password may contain a ':' character
      #
      # line - a line of text from a file
      #
      # Returns the individual parts of the line
      # Raises InvalidPasswdEntry if it is not an valid entry
      def is_entry!(line)
        raise InvalidPasswdEntry, "line commented out" if line =~ /\A#/
        parts = line.strip.split(":")
        raise InvalidPasswdEntry, "line must be of the format username:password" if parts.size != 2
        return parts
      end

      # Internal: Returns whether or not the line is a valid entry
      #
      # Returns true or false
      def is_entry?(line)
        begin
          is_entry!(line)
          return true
        rescue InvalidPasswdEntry
          return false
        end
      end
    end

    # Internal: Create a new Entry with the given user, password, and algorithm
    def initialize(user, password = nil, alg = Algorithm::DEFAULT, alg_params = {} )
      @user      = user
      alg = Algorithm::DEFAULT if alg == Algorithm::EXISTING 
      @algorithm = Algorithm.algorithm_from_name(alg, alg_params)
      @digest    = calc_digest(password)
    end

    # Internal: set the algorithm for the entry
    def algorithm=(alg)
      return @algorithm if Algorithm::EXISTING == alg
      case alg
      when String
        @algorithm = Algorithm.algorithm_from_name(alg)
      when ::HTAuth::Algorithm
        @algorithm = alg
      else
        raise InvalidAlgorithm, "Unable to assigne #{alg} to algorithm"
      end
      return @algorithm
    end

    # Internal: Update the password of the entry with its new value
    #
    # If we have an array of algorithms, then we set it to CRYPT
    def password=(new_password)
      if algorithm.kind_of?(HTAuth::Plaintext) then
        @algorithm = Algorithm.algorithm_from_name(Algorithm::CRYPT)
      end
      @digest = calc_digest(new_password)
    end

    # Internal: calculate the new digest of the given password
    def calc_digest(password)
      return nil unless password
      algorithm.encode(password)
    end

    # Public: Check if the given password is the password of this entry
    # check the password and make sure it works, in the case that the algorithm is unknown it
    # tries all of the ones that it thinks it could be, and marks the algorithm if it matches
    # when looking for a matche, we always compare all of them, no short
    # circuiting
    def authenticated?(check_password)
      authed = false
      if algorithm.kind_of?(Array) then
        algorithm.each do |alg|
          encoded = alg.encode(check_password)
          if Algorithm.secure_compare(encoded, digest) then
            @algorithm = alg
            authed = true
          end
        end
      else
        encoded = algorithm.encode(check_password)
        authed  = Algorithm.secure_compare(encoded, digest)
      end
      return authed
    end

    # Internal: Returns the key of this entry
    def key
      return "#{user}"
    end

    # Internal: Returns the file line for this entry
    def to_s
      "#{user}:#{digest}"
    end
  end
end
