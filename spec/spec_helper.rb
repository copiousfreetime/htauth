require 'rubygems'
require 'spec'

$: << File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))
require 'htauth'

PASSWD_ORIGINAL_TEST_FILE  = File.join(File.dirname(__FILE__), "test.original.passwd")
PASSWD_ADD_TEST_FILE       = File.join(File.dirname(__FILE__), "test.add.passwd")
PASSWD_UPDATE_TEST_FILE    = File.join(File.dirname(__FILE__), "test.update.passwd")
PASSWD_DELETE_TEST_FILE    = File.join(File.dirname(__FILE__), "test.delete.passwd")
PASSWD_COMMENTED_TEST_FILE = File.join(File.dirname(__FILE__), "test.comments.passwd")

DIGEST_ORIGINAL_TEST_FILE  = File.join(File.dirname(__FILE__), "test.original.digest")
DIGEST_ADD_TEST_FILE       = File.join(File.dirname(__FILE__), "test.add.digest")
DIGEST_UPDATE_TEST_FILE    = File.join(File.dirname(__FILE__), "test.update.digest")
DIGEST_DELETE_TEST_FILE    = File.join(File.dirname(__FILE__), "test.delete.digest")
DIGEST_COMMENTED_TEST_FILE = File.join(File.dirname(__FILE__), "test.comments.digest")
