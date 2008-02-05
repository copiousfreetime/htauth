require 'rpasswd/algorithm'
require 'digest/sha1'
require 'base64'

module Rpasswd

    # an implementation of the SHA based encoding algorithm 
    # as used in the apache htpasswd -s option
    class Sha1 < Algorithm
        def name
            "SHA"
        end

        def prefix
            "{SHA}"
        end

        def encode(password)
            Base64.encode64(SHA1.digest(password))
        end
    end
end
