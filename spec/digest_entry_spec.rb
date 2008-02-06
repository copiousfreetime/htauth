require File.join(File.dirname(__FILE__),"spec_helper.rb")

require 'htauth/digest_entry'

describe HTAuth::DigestEntry do
    before(:each) do
        @alice = HTAuth::DigestEntry.new("alice", "htauth")
        @bob   = HTAuth::DigestEntry.new("bob", "htauth", "b secret")
    end

    it "initializes with a user and realm" do
        @alice.user.should == "alice"
        @alice.realm.should == "htauth"
    end

    it "has the correct digest for a password" do
        @alice.password = "digit"
        @alice.digest.should == "4ed9e5744c6747af8f292d28afd6372e"
    end

    it "returns username:realm for a key" do
        @alice.key.should == "alice:htauth"
    end

    it "checks the password correctly" do
        @bob.authenticated?("b secret").should == true
    end

    it "formats correctly when put to a string" do
        @bob.to_s.should == "bob:htauth:fcbeab6821d2ab3b00934c958db0fd1e"
    end

    it "parses an input line" do
        @bob_new = HTAuth::DigestEntry.from_line("bob:htauth:fcbeab6821d2ab3b00934c958db0fd1e")
        @bob.user.should == @bob_new.user
        @bob.digest.should == @bob_new.digest
        @bob.realm.should == @bob_new.realm
    end

    it "knows if an input line is a possible entry and raises an exception" do
        lambda { HTAuth::DigestEntry.is_entry!("#stuff") }.should raise_error(HTAuth::InvalidDigestEntry)
        lambda { HTAuth::DigestEntry.is_entry!("this:that:other:stuff") }.should raise_error(HTAuth::InvalidDigestEntry)
        lambda { HTAuth::DigestEntry.is_entry!("this:that:other") }.should raise_error(HTAuth::InvalidDigestEntry)
        lambda { HTAuth::DigestEntry.is_entry!("this:that:0a90549e8ffb2dd62f98252a95d88xyz") }.should raise_error(HTAuth::InvalidDigestEntry)
    end
    
    it "knows if an input line is a possible entry and returns false" do
        HTAuth::DigestEntry.is_entry?("#stuff").should == false
        HTAuth::DigestEntry.is_entry?("this:that:other:stuff").should == false 
        HTAuth::DigestEntry.is_entry?("this:that:other").should == false 
        HTAuth::DigestEntry.is_entry?("this:that:0a90549e8ffb2dd62f98252a95d88xyz").should == false
    end
    
    it "knows if an input line is a possible entry and returns true" do
        HTAuth::DigestEntry.is_entry?("bob:htauth:0a90549e8ffb2dd62f98252a95d88697").should == true
    end

    it "duplicates itself" do
        @alice.dup.to_s.should == @alice.to_s
    end
end
