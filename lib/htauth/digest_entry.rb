require 'htauth/error'
require 'htauth/entry'
require 'digest/md5'

module HTAuth
  # Internal: Object version of a single record from an htdigest file
  class DigestEntry

    # Internal: The user of this entry
    attr_accessor :user
    # Internal: The realm of this entry
    attr_accessor :realm
    # Internal: The passwod digest of this entry
    attr_accessor :digest

    class << self
      # Internal: Create an instance of this class from a line of text
      #
      # line - a line of text from a htdigest file
      #
      # Returns an instance of DigestEntry
      def from_line(line)
        parts = is_entry!(line)
        d = DigestEntry.new(parts[0], parts[1])
        d.digest = parts[2]
        return d
      end

      # Internal: test if the given line is valid for this Entry class
      #
      # A valid entry must be composed of 3 parts, username:realm:md5sum where
      # username, and realm do not contain the ':' character; and md5sum must be
      # 32 characters long
      #
      # line - a line of text from a file
      #
      # Returns the individual parts of the line
      # Raises InvalidDigestEntry if it is not a a valid entry
      def is_entry!(line)
        raise InvalidDigestEntry, "line commented out" if line =~ /\A#/
        parts = line.strip.split(":")
        raise InvalidDigestEntry, "line must be of the format username:realm:md5checksum" if parts.size != 3
        raise InvalidDigestEntry, "md5 checksum is not 32 characters long" if parts.last.size  != 32
        raise InvalidDigestEntry, "md5 checksum has invalid characters" if parts.last !~ /\A[[:xdigit:]]{32}\Z/
        return parts
      end

      # Internal: Returns whether or not the line is a valid entry
      #
      # Returns true or false
      def is_entry?(line)
        begin
          is_entry!(line)
          return true
        rescue InvalidDigestEntry
          return false
        end
      end
    end

    # Internal: Create a new Entry with the given user, realm and password
    def initialize(user, realm, password = "")
      @user     = user
      @realm    = realm
      @digest   = calc_digest(password)
    end

    # Internal: Update the password of the entry with its new value
    def password=(new_password)
      @digest = calc_digest(new_password)
    end

    # Internal: calculate the new digest of the given password
    def calc_digest(password)
      ::Digest::MD5.hexdigest("#{user}:#{realm}:#{password}")
    end

    # Public: Check if the given password is the password of this entry.
    def authenticated?(check_password)
      hd = calc_digest(check_password)
      return hd == digest
    end

    # Internal: Returns the key of this entry
    def key
      "#{user}:#{realm}"
    end

    # Internal: Returns the file line for this entry
    def to_s
      "#{user}:#{realm}:#{digest}"
    end
  end
end
