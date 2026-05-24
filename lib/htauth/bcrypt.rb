# frozen_string_literal: true

require "htauth/algorithm"
require "bcrypt"

module HTAuth
  # Internal: an implementation of the Bcrypt based encoding algorithm
  # as used in the apache htpasswd -B option

  class Bcrypt < Algorithm
    attr_accessor :cost

    DEFAULT_APACHE_COST = 5 # this is the default cost from htpasswd

    def self.handles?(password_entry)
      ::BCrypt::Password.valid_hash?(password_entry)
    end

    def self.extract_cost_from_existing_password_field(existing)
      password = ::BCrypt::Password.new(existing)
      password.cost
    end

    def initialize(params = {})
      super()
      @cost = if (existing = params["existing"] || params[:existing])
                self.class.extract_cost_from_existing_password_field(existing)
              else
                params["cost"] || params[:cost] || DEFAULT_APACHE_COST
              end
    end

    def encode(password)
      ::BCrypt::Password.create(password, cost: cost)
    end

    def verify_password?(password, digest)
      bc = ::BCrypt::Password.new(digest)
      bc.is_password?(password)
    end
  end
end
