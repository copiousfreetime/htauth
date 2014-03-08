require 'htauth'
module HTAuth
  VERSION = "1.0.4"
  module Version
    STRING  = HTAuth::VERSION
    MAJOR   = to_a[0]
    MINOR   = to_a[1]
    BUILD   = to_a[2]

    def to_a
      STRING.split(".")
    end

    def to_s
      STRING
    end

    module_function :to_a
    module_function :to_s

  end
end
