module HTAuth
    
    ROOT_DIR        = ::File.expand_path(::File.join(::File.dirname(__FILE__),".."))
    LIB_DIR         = ::File.join(ROOT_DIR,"lib").freeze

    class FileAccessError < StandardError ; end
    class TempFileError < StandardError ; end
    class PasswordError < StandardError ; end
end

require 'htauth/version'
require 'htauth/gemspec'
require 'htauth/passwd'
require 'htauth/digest'
