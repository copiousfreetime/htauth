require 'htauth/algorithm'
require 'digest/sha1'
require 'base64'

module HTAuth

    # an implementation of the SHA based encoding algorithm 
    # as used in the apache htpasswd -s option
    class Sha1 < Algorithm
        
        # ignore the params
        def initialize(params = {}) 
        end

        def prefix
            "{SHA}"
        end

        def encode(password)
            "#{prefix}#{Base64.encode64(::Digest::SHA1.digest(password)).strip}"
        end
    end
end
