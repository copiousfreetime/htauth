require File.join(File.dirname(__FILE__),"spec_helper.rb")

require 'rpasswd/passwd_file'
require 'tempfile'

describe Rpasswd::PasswdFile do

    before(:each) do
        @tf             = Tempfile.new("rpasswrd-passwd")
        @tf.write(IO.read(PASSWD_ORIGINAL_TEST_FILE))
        @tf.close       
        @passwd_file    = Rpasswd::PasswdFile.new(@tf.path)
        
        @tf2                = Tempfile.new("rpasswrd-passwd-empty")
        @tf2.close
        @empty_passwd_file  = Rpasswd::PasswdFile.new(@tf2.path)
    end

    after(:each) do
        @tf2.close(true)
        @tf.close(true)
    end

    it "can add a new entry to an already existing passwd file" do
        @passwd_file.add_or_update("charlie", "c secret", "sha1")
        @passwd_file.contents.should == IO.read(PASSWD_ADD_TEST_FILE)
    end

    it "can tell if an entry already exists in the passwd file" do
        @passwd_file.has_entry?("alice").should == true
        @passwd_file.has_entry?("david").should == false
    end
    
    it "can update an entry in an already existing passwd file, algorithm can change" do
        @passwd_file.add_or_update("alice", "a new secret", "sha1")
        @passwd_file.contents.should == IO.read(PASSWD_UPDATE_TEST_FILE)
    end

    it "fetches a copy of an entry" do
        @passwd_file.fetch("alice").to_s.should == "alice:$apr1$DghnA...$CsPcgerfsI/Ryy0AOAJtb0"
    end

    it "raises an error if an attempt is made to alter a non-existenet file" do
        lambda { Rpasswd::PasswdFile.new("some-file") }.should raise_error(Rpasswd::FileAccessError)
    end

    # this test will only work on systems that have /etc/ssh_host_rsa_key 
    it "raises an error if an attempt is made to open a file where no permissions are granted" do
        lambda { Rpasswd::PasswdFile.new("/etc/ssh_host_rsa_key") }.should raise_error(Rpasswd::FileAccessError)
    end

    it "deletes an entry" do
        @passwd_file.delete("bob")
        @passwd_file.contents.should == IO.read(PASSWD_DELETE_TEST_FILE)
    end
end
