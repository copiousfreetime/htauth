require 'htauth/algorithm'
require 'argon2'

module HTAuth
  # Internal: a handlr for the argon2 password hashing algorithm
  # provided by https://rubygems.org/gems/argon2

  class Argon2 < Algorithm

    def self.handles?(password_entry)
    end

    def initialize(params = {})
    end

    def encode(password)
    end
  end
end
