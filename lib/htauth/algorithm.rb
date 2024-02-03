require 'htauth/error'
require 'htauth/descendant_tracker'
require 'securerandom'
module HTAuth
  class InvalidAlgorithmError < Error; end

  # Internal: Base class all the password algorithms derive from
  #
  class Algorithm

    extend DescendantTracker

    SALT_CHARS    = (%w[ . / ] + ("0".."9").to_a + ('A'..'Z').to_a + ('a'..'z').to_a).freeze
    SALT_LENGTH   = 8

    # Public: flag for the argon2 algorithm
    ARGON2        = "argon2".freeze
    # Public: flag for the bcrypt algorithm
    BCRYPT        = "bcrypt".freeze
    # Public: flag for the md5 algorithm
    MD5           = "md5".freeze
    # Public: flag for the sha1 algorithm
    SHA1          = "sha1".freeze
    # Public: flag for the plaintext algorithm
    PLAINTEXT     = "plaintext".freeze
    # Public: flag for the crypt algorithm
    CRYPT         = "crypt".freeze

    # Public: flag for the default algorithm
    DEFAULT       = MD5

    # Public: flag to indicate using the existing algorithm of the entry
    EXISTING      = "existing".freeze


    class << self
      def algorithm_name
        self.name.split("::").last.downcase
      end

      def algorithm_from_name(a_name, params = {})
        found = children.find { |c| c.algorithm_name == a_name }
        if !found then
          names = children.map { |c| c.algorithm_name }
          raise InvalidAlgorithmError, "`#{a_name}' is an unknown encryption algorithm, use one of #{names.join(', ')}"
        end
        return found.new(params)
      end

      # NOTE: if it is plaintext, and the length is 13 - it may matched crypt
      #       and be tested that way. If that is the case - this is explicitly
      #       siding with crypt() as you shouldn't be using plaintext. Or
      #       crypt for that matter.
      def algorithm_from_field(password_field)
        match = find_child(:handles?, password_field)
        match = ::HTAuth::Plaintext if match.nil? && ::HTAuth::Plaintext.entry_matches?(password_field)

        raise InvalidAlgorithmError, "unknown encryption algorithm used for `#{password_field}`" if match.nil?

        return match.new(:existing => password_field)
      end

      # Internal: Does this class handle this type of password entry
      #
      def handles?(password_entry)
        raise NotImplementedError, "#{self.name} must implement #{self.name}.handles?(password_entry)"
      end

      # Internal: Constant time string comparison.
      #
      # From https://github.com/rack/rack/blob/master/lib/rack/utils.rb
      #
      # NOTE: the values compared should be of fixed length, such as strings
      # that have already been processed by HMAC. This should not be used
      # on variable length plaintext strings because it could leak length info
      # via timing attacks.
      def secure_compare(a, b)
        return false unless a.bytesize == b.bytesize

        l = a.unpack("C*")

        r, i = 0, -1
        b.each_byte { |v| r |= v ^ l[i+=1] }
        r == 0
      end
    end

    # Internal
    def encode(password)
      raise NotImplementedError, "#{self.class.name} must implement #{self.class.name}.encode(password)"
    end

    # Internal: 8 bytes of random items from SALT_CHARS
    def gen_salt(length = SALT_LENGTH)
      Array.new(length) { SALT_CHARS.sample }.join('')
    end

    # Internal: this is not the Base64 encoding, this is the to64()
    # method from the Apache Portable Runtime (APR) library
    # https://github.com/apache/apr/blob/trunk/crypto/apr_md5.c#L493-L502
    def to_64(number, rounds)
      r = StringIO.new
      rounds.times do |x|
        r.print(SALT_CHARS[number % 64])
        number >>= 6
      end
      return r.string
    end
  end
end
