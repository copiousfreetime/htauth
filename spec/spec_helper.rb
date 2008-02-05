require 'rubygems'
require 'spec'

$: << File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))
require 'rpasswd'

ORIGINAL_TEST_FILE  = File.join(File.dirname(__FILE__), "test.original.digest")
ADD_TEST_FILE       = File.join(File.dirname(__FILE__), "test.add.digest")
UPDATE_TEST_FILE    = File.join(File.dirname(__FILE__), "test.update.digest")
DELETE_TEST_FILE    = File.join(File.dirname(__FILE__), "test.delete.digest")
COMMENTED_TEST_FILE = File.join(File.dirname(__FILE__), "test.comments.digest")
