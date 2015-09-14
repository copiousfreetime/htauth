require 'htauth/error'
require 'securerandom'
module HTAuth
  class InvalidAlgorithmError < Error; end

  # Internal: Base class all the password algorithms derive from
  #
  class Algorithm

    SALT_CHARS    = (%w[ . / ] + ("0".."9").to_a + ('A'..'Z').to_a + ('a'..'z').to_a).freeze

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
      def algorithm_from_name(a_name, params = {})
        raise InvalidAlgorithmError, "`#{a_name}' is an invalid encryption algorithm, use one of #{sub_klasses.keys.join(', ')}" unless sub_klasses[a_name.downcase]
        sub_klasses[a_name.downcase].new(params)
      end

      def algorithms_from_field(password_field)
        matches = []

        if password_field.index(sub_klasses[SHA1].new.prefix) then
          matches << sub_klasses[SHA1].new
        elsif password_field.index(sub_klasses[MD5].new.prefix) then
          p = password_field.split("$")
          matches << sub_klasses[MD5].new( :salt => p[2] )
        else
          matches << sub_klasses[PLAINTEXT].new
          matches << sub_klasses[CRYPT].new( :salt => password_field[0,2] )
        end

        return matches
      end

      def inherited(sub_klass)
        k = sub_klass.name.split("::").last.downcase
        sub_klasses[k] = sub_klass
      end

      def sub_klasses
        @sub_klasses ||= {}
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
    def prefix ; end

    # Internal
    def encode(password) ; end

    # Internal: 8 bytes of random items from SALT_CHARS
    def gen_salt
      chars = []
      8.times { chars << SALT_CHARS[SecureRandom.random_number(SALT_CHARS.size)] }
      chars.join('')
    end

    # Internal: this is not the Base64 encoding, this is the to64() 
    # method from the apache protable runtime library
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
