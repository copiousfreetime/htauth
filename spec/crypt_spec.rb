
require File.join(File.dirname(__FILE__),"spec_helper.rb")

require 'rpasswd/crypt'

describe HTAuth::Crypt do
    it "has a prefix" do
        HTAuth::Crypt.new.prefix.should == ""
    end

    it "encrypts the same way that apache does" do
        apache_salt = "L0LDd/.."
        apache_result = "L0ekWYm59LT1M"
        crypt = HTAuth::Crypt.new({ :salt => apache_salt} )
        crypt.encode("a secret").should == apache_result
    end
end

