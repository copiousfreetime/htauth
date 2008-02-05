require File.join(File.dirname(__FILE__),"spec_helper.rb")

require 'rpasswd/md5'

describe Rpasswd::Md5 do
    it "has a prefix" do
        Rpasswd::Md5.new.prefix.should == "$apr1$"
    end

    it "encrypts the same way that apache does" do
        apache_salt = "L0LDd/.."
        apache_result = "$apr1$L0LDd/..$yhUzDjpxam5F1kWdtwMco1"
        md5 = Rpasswd::Md5.new({ 'salt' => apache_salt })
        md5.encode("a secret").should == apache_result
    end
end

