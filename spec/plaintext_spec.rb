require 'spec_helper'
require 'htauth/plaintext'

describe HTAuth::Plaintext do
  it "has a prefix" do
    _(HTAuth::Plaintext.new.prefix).must_equal ""
  end

  it "encrypts the same way that apache does" do
    apache_result = "a secret"
    pt = HTAuth::Plaintext.new
    _(pt.encode("a secret")).must_equal apache_result
  end
end

