
require 'rpasswd/algorithm'

module Rpasswd

    # the plaintext algorithm, which does absolutly  nothing
    class Plaintext < Algorithm
        def name
            "plaintext"
        end

        def prefix
            ""
        end

        def encode(password)
            "#{password}"
        end
    end
end
