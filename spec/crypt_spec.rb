require 'spec_helper'
require 'htauth/crypt'

describe HTAuth::Crypt do
  it "has a prefix" do
    _(HTAuth::Crypt.new.prefix).must_equal ""
  end

  it "encrypts the same way that apache does" do
    apache_salt = "L0LDd/.."
    apache_result = "L0ekWYm59LT1M"
    crypt = HTAuth::Crypt.new({ :salt => apache_salt} )
    _(crypt.encode("a secret")).must_equal apache_result
  end
end

