

require File.join(File.dirname(__FILE__),"spec_helper.rb")

require 'rpasswd/sha1'

describe Rpasswd::Plaintext do
    it "has a prefix" do
        Rpasswd::Plaintext.new.prefix.should == ""
    end

    it "has a name" do
        Rpasswd::Plaintext.new.name.should == "plaintext"
    end

    it "encrypts the same way that apache does" do
        apache_result = "a secret"
        pt = Rpasswd::Plaintext.new
        pt.encode("a secret").should == apache_result
    end
end

