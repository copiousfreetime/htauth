require 'htauth/algorithm'

module HTAuth
  # Internal: The basic crypt algorithm
  class Crypt < Algorithm

    ENTRY_LENGTH = 13
    ENTRY_REGEX = %r{\A[^$:\s]{#{ENTRY_LENGTH}}\z}

    def self.handles?(password_entry)
      ENTRY_REGEX.match?(password_entry)
    end

    def self.extract_salt_from_existing_password_field(existing)
      existing[0,2]
    end

    def initialize(params = {})
      if existing = (params['existing'] || params[:existing]) then
        @salt = self.class.extract_salt_from_existing_password_field(existing)
      else
        @salt = params[:salt] || params['salt'] || gen_salt
      end
    end

    def encode(password)
      password.crypt(@salt)
    end
  end
end
