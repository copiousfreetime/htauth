require File.join(File.dirname(__FILE__),"spec_helper.rb")

require 'htauth/md5'

describe HTAuth::Md5 do
    it "has a prefix" do
        HTAuth::Md5.new.prefix.must_equal "$apr1$"
    end

    it "encrypts the same way that apache does" do
        apache_salt = "L0LDd/.."
        apache_result = "$apr1$L0LDd/..$yhUzDjpxam5F1kWdtwMco1"
        md5 = HTAuth::Md5.new({ 'salt' => apache_salt })
        md5.encode("a secret").must_equal apache_result
    end
end

