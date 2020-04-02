require 'spec_helper'
require 'htauth/plaintext'

describe HTAuth::Plaintext do
  it "encrypts the same way that apache does" do
    apache_result = "a secret"
    pt = HTAuth::Plaintext.new
    _(pt.encode("a secret")).must_equal apache_result
  end
end

