require 'htauth/algorithm'

module HTAuth
  # Internal: the plaintext algorithm, which does absolutly nothing
  class Plaintext < Algorithm

    ENTRY_REGEX = /\A[^$:]*\Z/

    def self.entry_matches?(entry)
      ENTRY_REGEX.match?(entry)
    end

    def self.handles?(password_entry)
      false
    end

    # ignore parameters
    def initialize(params = {})
    end

    def encode(password)
      "#{password}"
    end
  end
end
