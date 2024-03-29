require 'htauth/algorithm'
begin
  require 'argon2'
rescue LoadError
end

module HTAuth
  # Internal:  Support of the argon2id algorithm and password format.

  class Argon2 < Algorithm
    class NotSupportedError < ::HTAuth::InvalidAlgorithmError
      def message
        "Unfortunately Argon2 passwords are not supported on `#{RUBY_PLATFORM} at this time. This because the upstream argon2 gem does not support windows."
      end
    end
    class NotInstalledError < ::HTAuth::InvalidAlgorithmError
      def message
        "Argon2 passwords are supported if the `argon2' gem is installed. Add `gem 'argon2', '~> 2.3'` to your Gemfile"
      end
    end

    # from upstream, used to help make a nice error message if its not installed
    # https://github.com/technion/ruby-argon2/blob/3388d7e05e8b486ea4ba8bd2aeb1e9988f025f13/lib/argon2/hash_format.rb#L45
    PREFIX = /^\$argon2(id?|d).{,113}/.freeze
    ARGON2_GEM_INSTALLED = defined?(::Argon2)

    def self.supported?
      !::Gem.win_platform?
    end

    def self.ensure_available!
      raise NotSupportedError unless supported?
      raise NotInstalledError unless ARGON2_GEM_INSTALLED
    end

    attr_accessor :options

     def self.handles?(password_entry)
      return false unless PREFIX.match?(password_entry)
      ensure_available!

      return ::Argon2::Password.valid_hash?(password_entry)
     end

     def self.extract_options_from_existing_password_field(existing)
       hash_format = ::Argon2::HashFormat.new(existing)

       # m_cost on the input is the 2**m_cost, but in the hash its the number of
       # bytes, so need to convert it back to a power of 2, which is the
       # log2(m_cost)

       {
         t_cost: hash_format.t_cost,
         m_cost: ::Math.log2(hash_format.m_cost).floor,
         p_cost: hash_format.p_cost,
       }
     end

     def initialize(params = { profile: :rfc_9106_low_memory })
       self.class.ensure_available!
       if existing = (params['existing'] || params[:existing]) then
         @options = self.class.extract_options_from_existing_password_field(existing)
       else
         @options = params
       end
     end

     def encode(password)
       argon2 = ::Argon2::Password.new(options)
       argon2.create(password)
     end

    def verify_password?(password, digest)
      ::Argon2::Password.verify_password(password, digest)
    end
  end
end
