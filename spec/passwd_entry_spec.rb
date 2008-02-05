
require File.join(File.dirname(__FILE__),"spec_helper.rb")

require 'rpasswd/passwd_entry'

describe Rpasswd::PasswdEntry do
    before(:each) do
        @alice = Rpasswd::PasswdEntry.new("alice", "a secret", 'crypt', { :salt => "mD" })
        @bob   = Rpasswd::PasswdEntry.new("bob", "b secret", 'crypt', { :salt => "b8"})
    end

    it "initializes with a user and realm" do
        @alice.user.should == "alice"
    end

    it "has the correct crypt password" do
        @alice.password = "a secret"
        @alice.digest.should == "mDwdZuXalQ5zk"
    end

    it "should encrypt correctly for md5" do
        bob = Rpasswd::PasswdEntry.new("bob", "b secret", "md5", { :salt => "lo1tk/.." })
        bob.digest.should == "$apr1$lo1tk/..$CarApvZPee0F6Wj1U0GxZ1"
    end
    
    it "should encrypt correctly for sha1" do
        bob = Rpasswd::PasswdEntry.new("bob", "b secret", "sha1", { :salt => @salt })
        bob.digest.should == "{SHA}b/tjGXbX80MEKVnF200S43ca4hY="
    end
    
    it "should encrypt correctly for plaintext" do
        bob = Rpasswd::PasswdEntry.new("bob", "b secret", "plaintext", { :salt => @salt })
        bob.digest.should == "b secret"
    end

    it "returns username for a key" do
        @alice.key.should == "alice"
    end

    it "checks the password correctly" do
        @bob.authenticated?("b secret").should == true
    end

    it "formats correctly when put to a string" do
        @bob.to_s.should == "bob:b8Ml4Jp9I0N8E"
    end

    it "parses an input line" do
        @bob_new = Rpasswd::PasswdEntry.from_line("bob:b8Ml4Jp9I0N8E")
        @bob.user.should == @bob_new.user
        @bob.digest.should == @bob_new.digest
    end

    it "knows if an input line is a possible entry and raises an exception" do
        lambda { Rpasswd::PasswdEntry.is_entry!("#stuff") }.should raise_error(Rpasswd::InvalidPasswdEntry)
        lambda { Rpasswd::PasswdEntry.is_entry!("this:that:other:stuff") }.should raise_error(Rpasswd::InvalidPasswdEntry)
        lambda { Rpasswd::PasswdEntry.is_entry!("this:that:other") }.should raise_error(Rpasswd::InvalidPasswdEntry)
        lambda { Rpasswd::PasswdEntry.is_entry!("this:that:0a90549e8ffb2dd62f98252a95d88xyz") }.should raise_error(Rpasswd::InvalidPasswdEntry)
    end
    
    it "knows if an input line is a possible entry and returns false" do
        Rpasswd::PasswdEntry.is_entry?("#stuff").should == false
        Rpasswd::PasswdEntry.is_entry?("this:that:other:stuff").should == false 
        Rpasswd::PasswdEntry.is_entry?("this:that:other").should == false 
        Rpasswd::PasswdEntry.is_entry?("this:that:0a90549e8ffb2dd62f98252a95d88xyz").should == false
    end
    
    it "knows if an input line is a possible entry and returns true" do
        Rpasswd::PasswdEntry.is_entry?("bob:irRm0g.SDfCyI").should == true
        Rpasswd::PasswdEntry.is_entry?("bob:b secreat").should == true
        Rpasswd::PasswdEntry.is_entry?("bob:{SHA}b/tjGXbX80MEKVnF200S43ca4hY=").should == true
        Rpasswd::PasswdEntry.is_entry?("bob:$apr1$lo1tk/..$CarApvZPee0F6Wj1U0GxZ1").should == true

    end

    it "duplicates itself" do
        @alice.dup.to_s.should == @alice.to_s
    end
end
