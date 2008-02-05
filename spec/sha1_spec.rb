
require File.join(File.dirname(__FILE__),"spec_helper.rb")

require 'rpasswd/sha1'

describe Rpasswd::Sha1 do
    it "has a prefix" do
        Rpasswd::Sha1.new.prefix.should == "{SHA}"
    end

    it "encrypts the same way that apache does" do
        apache_result = "{SHA}ZrnlrvmM7ZCOV3FAvM7la89NKbk="
        sha1 = Rpasswd::Sha1.new
        sha1.encode("a secret").should == apache_result
    end
end

