

require File.join(File.dirname(__FILE__),"spec_helper.rb")

require 'rpasswd/sha1'

describe HTAuth::Plaintext do
    it "has a prefix" do
        HTAuth::Plaintext.new.prefix.should == ""
    end

    it "encrypts the same way that apache does" do
        apache_result = "a secret"
        pt = HTAuth::Plaintext.new
        pt.encode("a secret").should == apache_result
    end
end

