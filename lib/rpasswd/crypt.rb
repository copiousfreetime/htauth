require 'rpasswd/algorithm'

module Rpasswd

    # The basic crypt algorithm
    class Crypt < Algorithm
        
        def initialize(in_salt = nil)
            @salt = in_salt || gen_salt
        end

        def name
            "crypt"
        end

        def prefix
            ""
        end

        def encode(password)
            password.crypt(@salt)
        end
    end
end
