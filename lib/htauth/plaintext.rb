require 'htauth/algorithm'

module HTAuth

  # the plaintext algorithm, which does absolutly  nothing
  class Plaintext < Algorithm
    # ignore parameters
    def initialize(params = {})
    end

    def prefix
      ""
    end

    def encode(password)
      "#{password}"
    end
  end
end
