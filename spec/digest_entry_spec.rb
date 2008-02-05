require File.join(File.dirname(__FILE__),"spec_helper.rb")

require 'rpasswd/digest_entry'

describe Rpasswd::DigestEntry do
    before(:each) do
        @alice = Rpasswd::DigestEntry.new("alice", "rpasswd")
        @bob   = Rpasswd::DigestEntry.new("bob", "rpasswd", "a secret")
    end

    it "initializes with a user and realm" do
        @alice.user.should == "alice"
        @alice.realm.should == "rpasswd"
    end

    it "has the correct digest for a password" do
        @alice.password = "digit"
        @alice.digest.should == "6977d799113273ade6d0738b1af3087b"
    end

    it "returns username:realm for a key" do
        @alice.key.should == "alice:rpasswd"
    end

    it "checks the password correctly" do
        @bob.authenticated?("a secret").should == true
    end

    it "formats correctly when put to a string" do
        @bob.to_s.should == "bob:rpasswd:0a90549e8ffb2dd62f98252a95d88697"
    end

    it "parses an input line" do
        @bob_new = Rpasswd::DigestEntry.from_line("bob:rpasswd:0a90549e8ffb2dd62f98252a95d88697")
        @bob.user.should == @bob_new.user
        @bob.digest.should == @bob_new.digest
        @bob.realm.should == @bob_new.realm
    end

    it "knows if an input line is a possible entry and raises an exception" do
        lambda { Rpasswd::DigestEntry.is_entry!("#stuff") }.should raise_error(Rpasswd::InvalidDigestEntry)
        lambda { Rpasswd::DigestEntry.is_entry!("this:that:other:stuff") }.should raise_error(Rpasswd::InvalidDigestEntry)
        lambda { Rpasswd::DigestEntry.is_entry!("this:that:other") }.should raise_error(Rpasswd::InvalidDigestEntry)
        lambda { Rpasswd::DigestEntry.is_entry!("this:that:0a90549e8ffb2dd62f98252a95d88xyz") }.should raise_error(Rpasswd::InvalidDigestEntry)
    end
    
    it "knows if an input line is a possible entry and returns false" do
        Rpasswd::DigestEntry.is_entry?("#stuff").should == false
        Rpasswd::DigestEntry.is_entry?("this:that:other:stuff").should == false 
        Rpasswd::DigestEntry.is_entry?("this:that:other").should == false 
        Rpasswd::DigestEntry.is_entry?("this:that:0a90549e8ffb2dd62f98252a95d88xyz").should == false
    end
    
    it "knows if an input line is a possible entry and returns true" do
        Rpasswd::DigestEntry.is_entry?("bob:rpasswd:0a90549e8ffb2dd62f98252a95d88697").should == true
    end

    it "duplicates itself" do
        @alice.dup.to_s.should == @alice.to_s
    end
end
