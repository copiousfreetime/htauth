require 'rpasswd/algorithm'
require 'digest/md5'

module Rpasswd

    # an implementation of the MD5 based encoding algorithm 
    # as used in the apache htpasswd -m option
    class Md5 < Algorithm

        SALT_CHARS    = (%w[ . / ] + ("0".."9").to_a + ('A'..'Z').to_a + ('a'..'z').to_a).freeze
        DIGEST_LENGTH = 16

        def initialize(in_salt = nil)
            @salt = in_salt || gen_salt
        end

        def name
            "MD5"
        end

        def prefix
            "$apr1$"
        end

        # this algorigthm pulled straight from apr_md5_encode() and converted to ruby syntax
        def encode(password)
            primary = ::Digest::MD5.new
            primary << password
            primary << prefix
            primary << @salt

            md5_t = ::Digest::MD5.digest("#{password}#{@salt}#{password}")

            l = password.length
            while l > 0 do
                slice_size = ( l > DIGEST_LENGTH ) ? DIGEST_LENGTH : l
                primary << md5_t[0, slice_size]
                l -= DIGEST_LENGTH
            end

            # weirdness
            l = password.length
            while l != 0
                case (l & 1)
                when 1
                    primary << 0.chr
                when 0
                    primary << password[0,1]
                end
                l >>= 1
            end

            pd = primary.digest
            
            encoded_password = "#{prefix}#{@salt}$"

            # apr_md5_encode has this comment about a 60Mhz Pentium above this loop.
            1000.times do |x|
                ctx = ::Digest::MD5.new
                ctx << (( ( x & 1 ) == 1 ) ? password : pd[0,DIGEST_LENGTH])
                (ctx << @salt) unless ( x % 3 ) == 0
                (ctx << password) unless ( x % 7 ) == 0
                ctx << (( ( x & 1 ) == 0 ) ? password : pd[0,DIGEST_LENGTH])
                pd = ctx.digest
            end


            l = (pd[ 0]<<16) | (pd[ 6]<<8) | pd[12]
            encoded_password << to_64(l, 4)

            l = (pd[ 1]<<16) | (pd[ 7]<<8) | pd[13]
            encoded_password << to_64(l, 4)

            l = (pd[ 2]<<16) | (pd[ 8]<<8) | pd[14]
            encoded_password << to_64(l, 4)

            l = (pd[ 3]<<16) | (pd[ 9]<<8) | pd[15]
            encoded_password << to_64(l, 4)

            l = (pd[ 4]<<16) | (pd[10]<<8) | pd[ 5]
            encoded_password << to_64(l, 4)
            encoded_password << to_64(pd[11],2)

            return encoded_password
        end

        private

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
