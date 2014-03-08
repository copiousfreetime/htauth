module HTAuth
  class InvalidAlgorithmError < StandardError ; end
  # base class all the Passwd algorithms derive from
  class Algorithm

    SALT_CHARS    = (%w[ . / ] + ("0".."9").to_a + ('A'..'Z').to_a + ('a'..'z').to_a).freeze
    DEFAULT       = "md5"
    EXISTING      = "existing"

    class << self
      def algorithm_from_name(a_name, params = {})
        raise InvalidAlgorithmError, "`#{a_name}' is an invalid encryption algorithm, use one of #{sub_klasses.keys.join(', ')}" unless sub_klasses[a_name.downcase]
        sub_klasses[a_name.downcase].new(params)
      end

      def algorithms_from_field(password_field)
        matches = []

        if password_field.index(sub_klasses['sha1'].new.prefix) then
          matches << sub_klasses['sha1'].new
        elsif password_field.index(sub_klasses['md5'].new.prefix) then
          p = password_field.split("$")
          matches << sub_klasses['md5'].new( :salt => p[2] )
        else
          matches << sub_klasses['plaintext'].new
          matches << sub_klasses['crypt'].new( :salt => password_field[0,2] )
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
    end

    def prefix ; end
    def encode(password) ; end

    # 8 bytes of random items from SALT_CHARS
    def gen_salt
      chars = []
      8.times { chars << SALT_CHARS[rand(SALT_CHARS.size)] }
      chars.join('')     
    end

    # this is not the Base64 encoding, this is the to64() method from apr
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
