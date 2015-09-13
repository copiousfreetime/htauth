require 'htauth/algorithm'

module HTAuth
  # Internal: The basic crypt algorithm
  class Crypt < Algorithm

    def initialize(params = {})
      @salt = params[:salt] || params['salt'] || gen_salt
    end

    def prefix
      ""
    end

    def encode(password)
      password.crypt(@salt)
    end
  end
end
