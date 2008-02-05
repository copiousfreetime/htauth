
require File.join(File.dirname(__FILE__),"spec_helper.rb")

require 'rpasswd/crypt'

describe Rpasswd::Crypt do
    it "has a prefix" do
        Rpasswd::Crypt.new.prefix.should == ""
    end

    it "has a name" do
        Rpasswd::Crypt.new.name.should == "crypt"
    end

    it "encrypts the same way that apache does" do
        apache_salt = "L0LDd/.."
        apache_result = "L0ekWYm59LT1M"
        crypt = Rpasswd::Crypt.new(apache_salt)
        crypt.encode("a secret").should == apache_result
    end
end

