
require File.join(File.dirname(__FILE__),"spec_helper.rb")

require 'rpasswd/passwd_entry'

describe HTAuth::PasswdEntry do
    before(:each) do
        @alice = HTAuth::PasswdEntry.new("alice", "a secret", "crypt", { :salt => "mD" })
        @bob   = HTAuth::PasswdEntry.new("bob", "b secret", "crypt", { :salt => "b8"})
    end

    it "initializes with a user and realm" do
        @alice.user.should == "alice"
    end

    it "has the correct crypt password" do
        @alice.password = "a secret"
        @alice.digest.should == "mDwdZuXalQ5zk"
    end

    it "should encrypt correctly for md5" do
        bob = HTAuth::PasswdEntry.new("bob", "b secret", "md5", { :salt => "lo1tk/.." })
        bob.digest.should == "$apr1$lo1tk/..$CarApvZPee0F6Wj1U0GxZ1"
    end
    
    it "should encrypt correctly for sha1" do
        bob = HTAuth::PasswdEntry.new("bob", "b secret", "sha1", { :salt => @salt })
        bob.digest.should == "{SHA}b/tjGXbX80MEKVnF200S43ca4hY="
    end
    
    it "should encrypt correctly for plaintext" do
        bob = HTAuth::PasswdEntry.new("bob", "b secret", "plaintext", { :salt => @salt })
        bob.digest.should == "b secret"
    end

    it "encrypts with crypt as a default, when parsed from crypt()'d line" do
        bob2 = HTAuth::PasswdEntry.from_line(@bob.to_s)
        bob2.algorithm.should be_an_instance_of(Array)
        bob2.algorithm.should have(2).items
        bob2.password = "another secret"
        bob2.algorithm.should be_an_instance_of(HTAuth::Crypt)
    end

    it "encrypts with crypt as a default, when parsed from plaintext line" do
        p = HTAuth::PasswdEntry.new('paul', 'p secret', 'plaintext')
        p2 = HTAuth::PasswdEntry.from_line(p.to_s)
        p2.algorithm.should be_an_instance_of(Array)
        p2.algorithm.should have(2).items
        p2.password = "another secret"
        p2.algorithm.should be_an_instance_of(HTAuth::Crypt)
    end

    it "encrypts with md5 as default, when parsed from an md5 line" do
        m = HTAuth::PasswdEntry.new("mary", "m secret", "md5") 
        m2 = HTAuth::PasswdEntry.from_line(m.to_s)
        m2.algorithm.should be_an_instance_of(HTAuth::Md5)
    end
    
    it "encrypts with sha1 as default, when parsed from an sha1 line" do
        s = HTAuth::PasswdEntry.new("steve", "s secret", "sha1") 
        s2 = HTAuth::PasswdEntry.from_line(s.to_s)
        s2.algorithm.should be_an_instance_of(HTAuth::Sha1)
    end

    it "determins the algorithm to be crypt when checking a password" do
        bob2 = HTAuth::PasswdEntry.from_line(@bob.to_s)
        bob2.algorithm.should be_an_instance_of(Array)
        bob2.algorithm.should have(2).items
        bob2.authenticated?("b secret").should == true
        bob2.algorithm.should be_an_instance_of(HTAuth::Crypt)
    end
    
    it "determins the algorithm to be plain when checking a password" do
        bob2 = HTAuth::PasswdEntry.from_line("bob:b secret")
        bob2.algorithm.should be_an_instance_of(Array)
        bob2.algorithm.should have(2).items
        bob2.authenticated?("b secret").should == true
        bob2.algorithm.should be_an_instance_of(HTAuth::Plaintext)
    end

    it "authenticates correctly against md5" do
        m = HTAuth::PasswdEntry.new("mary", "m secret", "md5") 
        m2 = HTAuth::PasswdEntry.from_line(m.to_s)
        m2.authenticated?("m secret").should == true
    end
    
    it "authenticates correctly against sha1" do
        s = HTAuth::PasswdEntry.new("steve", "s secret", "sha1") 
        s2 = HTAuth::PasswdEntry.from_line(s.to_s)
        s2.authenticated?("s secret").should == true
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
        @bob_new = HTAuth::PasswdEntry.from_line("bob:b8Ml4Jp9I0N8E")
        @bob.user.should == @bob_new.user
        @bob.digest.should == @bob_new.digest
    end

    it "knows if an input line is a possible entry and raises an exception" do
        lambda { HTAuth::PasswdEntry.is_entry!("#stuff") }.should raise_error(HTAuth::InvalidPasswdEntry)
        lambda { HTAuth::PasswdEntry.is_entry!("this:that:other:stuff") }.should raise_error(HTAuth::InvalidPasswdEntry)
        lambda { HTAuth::PasswdEntry.is_entry!("this:that:other") }.should raise_error(HTAuth::InvalidPasswdEntry)
        lambda { HTAuth::PasswdEntry.is_entry!("this:that:0a90549e8ffb2dd62f98252a95d88xyz") }.should raise_error(HTAuth::InvalidPasswdEntry)
    end
    
    it "knows if an input line is a possible entry and returns false" do
        HTAuth::PasswdEntry.is_entry?("#stuff").should == false
        HTAuth::PasswdEntry.is_entry?("this:that:other:stuff").should == false 
        HTAuth::PasswdEntry.is_entry?("this:that:other").should == false 
        HTAuth::PasswdEntry.is_entry?("this:that:0a90549e8ffb2dd62f98252a95d88xyz").should == false
    end
    
    it "knows if an input line is a possible entry and returns true" do
        HTAuth::PasswdEntry.is_entry?("bob:irRm0g.SDfCyI").should == true
        HTAuth::PasswdEntry.is_entry?("bob:b secreat").should == true
        HTAuth::PasswdEntry.is_entry?("bob:{SHA}b/tjGXbX80MEKVnF200S43ca4hY=").should == true
        HTAuth::PasswdEntry.is_entry?("bob:$apr1$lo1tk/..$CarApvZPee0F6Wj1U0GxZ1").should == true

    end

    it "duplicates itself" do
        @alice.dup.to_s.should == @alice.to_s
    end
end
