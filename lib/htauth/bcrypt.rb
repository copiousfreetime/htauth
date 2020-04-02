require 'htauth/algorithm'
require 'bcrypt'

module HTAuth
  # Internal: an implementation of the Bcrypt based encoding algorithm
  # as used in the apache htpasswd -B option

  class Bcrypt < Algorithm

    attr_accessor :cost

    DEFAULT_APACHE_COST = 5 # this is the default cost from htpasswd

    def self.handles?(password_entry)
      return ::BCrypt::Password.valid_hash?(password_entry)
    end

    def self.extract_cost_from_existing_password_field(existing)
      password = ::BCrypt::Password.new(existing)
      password.cost
    end

    def initialize(params = {})
      if existing = (params['existing'] || params[:existing]) then
        @cost = self.class.extract_cost_from_existing_password_field(existing)
      else
        @cost = params['cost'] || params[:cost] || DEFAULT_APACHE_COST
      end
    end

    def encode(password)
      ::BCrypt::Password.create(password, :cost => cost)
    end
  end
end
