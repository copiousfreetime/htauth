require 'spec_helper'
require 'htauth/sha1'

describe HTAuth::Sha1 do
    it "has a prefix" do
        HTAuth::Sha1.new.prefix.should == "{SHA}"
    end

    it "encrypts the same way that apache does" do
        apache_result = "{SHA}ZrnlrvmM7ZCOV3FAvM7la89NKbk="
        sha1 = HTAuth::Sha1.new
        sha1.encode("a secret").should == apache_result
    end
end

