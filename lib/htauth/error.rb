#-- 
# Copyrigth (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details
#++

module HTAuth
  class Error < StandardError; end

  class ConsoleError < Error; end
  class DigestFileError < Error ; end
  class FileAccessError < Error; end
  class InvalidDigestEntry < Error; end
  class InvalidPasswdEntry < Error ; end
  class PasswordError < Error; end
  class PasswdFileError < Error ; end
  class TempFileError < Error; end
end

