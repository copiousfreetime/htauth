require 'htauth/errors'
require 'htauth/entry'
require 'digest/md5'

module HTAuth
  class InvalidDigestEntry < StandardError ; end

  # A single record in an htdigest file.  
  class DigestEntry

    attr_accessor :user
    attr_accessor :realm
    attr_accessor :digest

    class << self
      def from_line(line)
        parts = is_entry!(line)
        d = DigestEntry.new(parts[0], parts[1])
        d.digest = parts[2]
        return d
      end

      # test if a line is an entry, raise InvalidDigestEntry if it is not.
      # an entry must be composed of 3 parts, username:realm:md5sum
      # where username, and realm do not contain the ':' character 
      # and the md5sum must be 32 characters long.
      def is_entry!(line)
        raise InvalidDigestEntry, "line commented out" if line =~ /\A#/
        parts = line.strip.split(":")
        raise InvalidDigestEntry, "line must be of the format username:realm:md5checksum" if parts.size != 3
        raise InvalidDigestEntry, "md5 checksum is not 32 characters long" if parts.last.size  != 32
        raise InvalidDigestEntry, "md5 checksum has invalid characters" if parts.last !~ /\A[[:xdigit:]]{32}\Z/
        return parts
      end

      # test if a line is an entry and return true or false
      def is_entry?(line)
        begin
          is_entry!(line)
          return true
        rescue InvalidDigestEntry
          return false
        end
      end
    end

    def initialize(user, realm, password = "")
      @user     = user
      @realm    = realm
      @digest   = calc_digest(password)
    end

    def password=(new_password)
      @digest = calc_digest(new_password)
    end

    def calc_digest(password)
      ::Digest::MD5.hexdigest("#{user}:#{realm}:#{password}")
    end

    def authenticated?(check_password)
      hd = ::Digest::MD5.hexdigest("#{user}:#{realm}:#{check_password}")
      return hd == digest
    end

    def key
      "#{user}:#{realm}"
    end

    def to_s
      "#{user}:#{realm}:#{digest}"
    end
  end
end
