require 'rpasswd/algorithm'

module Rpasswd

    # The basic crypt algorithm
    class Crypt < Algorithm
        
        def initialize(params = {})
            @salt = params[:salt] || params['salt'] || gen_salt
        end

        def prefix
            ""
        end

        def encode(password)
            password.crypt(@salt)
        end
    end
end
