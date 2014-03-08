#-- 
# Copyrigth (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details
#++

module HTAuth

  # The root directory of the project is considered to be the parent directory
  # of the 'lib' directory.
  #
  def self.root_dir
    unless @root_dir
      path_parts = ::File.expand_path( __FILE__ ).split( ::File::SEPARATOR )
      lib_index  = path_parts.rindex( 'lib' )
      @root_dir  = path_parts[ 0...lib_index].join( ::File::SEPARATOR ) + ::File::SEPARATOR
    end
    return @root_dir
  end

  def self.lib_path( *args )
    self.sub_path( "lib", *args )
  end

  def self.sub_path( sub, *args )
    sp = ::File.join( root_dir, sub ) + ::File::SEPARATOR
    sp = ::File.join( sp, *args ) if args
  end

end

require 'htauth/version'
require 'htauth/algorithm'
require 'htauth/crypt'
require 'htauth/digest'
require 'htauth/digest_entry'
require 'htauth/digest_file'
require 'htauth/entry'
require 'htauth/errors'
require 'htauth/file'
require 'htauth/md5'
require 'htauth/passwd'
require 'htauth/passwd_entry'
require 'htauth/passwd_file'
require 'htauth/plaintext'
require 'htauth/sha1'

