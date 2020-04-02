require 'spec_helper'
require 'htauth/sha1'

describe HTAuth::Sha1 do
  it "encrypts the same way that apache does" do
    apache_result = "{SHA}ZrnlrvmM7ZCOV3FAvM7la89NKbk="
    sha1 = HTAuth::Sha1.new
    _(sha1.encode("a secret")).must_equal apache_result
  end
end

