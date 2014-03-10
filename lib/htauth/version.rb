module HTAuth
  VERSION = "1.1.0"
  module Version
    STRING  = HTAuth::VERSION
    def to_a
      STRING.split(".")
    end

    def to_s
      STRING
    end

    module_function :to_a
    module_function :to_s

    MAJOR   = Version.to_a[0]
    MINOR   = Version.to_a[1]
    BUILD   = Version.to_a[2]

  end
end
