module Rpasswd
    # base class all the Passwd algorithms derive from
    class Algorithm
        SALT_CHARS    = (%w[ . / ] + ("0".."9").to_a + ('A'..'Z').to_a + ('a'..'z').to_a).freeze

        def name ; end
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
