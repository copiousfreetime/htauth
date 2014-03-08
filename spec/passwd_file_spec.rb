require 'spec_helper'
require 'htauth/passwd_file'
require 'tempfile'

describe HTAuth::PasswdFile do

    before(:each) do
        @tf             = Tempfile.new("rpasswrd-passwd")
        @tf.write(IO.read(PASSWD_ORIGINAL_TEST_FILE))
        @tf.close       
        @passwd_file    = HTAuth::PasswdFile.new(@tf.path)
        
        @tf2                = Tempfile.new("rpasswrd-passwd-empty")
        @tf2.close
        @empty_passwd_file  = HTAuth::PasswdFile.new(@tf2.path)
    end

    after(:each) do
        @tf2.close(true)
        @tf.close(true)
    end

    it "can add a new entry to an already existing passwd file" do
        @passwd_file.add_or_update("charlie", "c secret", "sha1")
        @passwd_file.contents.must_equal IO.read(PASSWD_ADD_TEST_FILE)
    end

    it "can tell if an entry already exists in the passwd file" do
        @passwd_file.has_entry?("alice").must_equal true
        @passwd_file.has_entry?("david").must_equal false
    end
    
    it "can update an entry in an already existing passwd file, algorithm can change" do
        @passwd_file.add_or_update("alice", "a new secret", "sha1")
        @passwd_file.contents.must_equal IO.read(PASSWD_UPDATE_TEST_FILE)
    end

    it "fetches a copy of an entry" do
        @passwd_file.fetch("alice").to_s.must_equal "alice:$apr1$DghnA...$CsPcgerfsI/Ryy0AOAJtb0"
    end

    it "raises an error if an attempt is made to alter a non-existenet file" do
        lambda { HTAuth::PasswdFile.new("some-file") }.must_raise(HTAuth::FileAccessError)
    end

    # this test will only work on systems that have /etc/ssh_host_rsa_key 
    it "raises an error if an attempt is made to open a file where no permissions are granted" do
        lambda { HTAuth::PasswdFile.new("/etc/ssh_host_rsa_key") }.must_raise(HTAuth::FileAccessError)
    end

    it "deletes an entry" do
        @passwd_file.delete("bob")
        @passwd_file.contents.must_equal IO.read(PASSWD_DELETE_TEST_FILE)
    end

    it "is usable in a ruby manner and yeilds itself when opened" do
        HTAuth::PasswdFile.open(@tf.path) do |pf|
            pf.add_or_update("alice", "a new secret", "md5")
            pf.delete('bob')
        end
        lines = IO.readlines(@tf.path)
        lines.size.must_equal 1
        lines.first.split(':').first.must_equal "alice"
        lines.first.split(':').last.must_match( /\$apr1\$/ )
    end
end
