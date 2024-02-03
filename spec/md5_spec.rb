require 'spec_helper'

describe HTAuth::Md5 do
  it "encrypts the same way that apache does" do
    apache_salt = "L0LDd/.."
    apache_result = "$apr1$L0LDd/..$yhUzDjpxam5F1kWdtwMco1"
    md5 = HTAuth::Md5.new({ 'salt' => apache_salt })
    _(md5.encode("a secret")).must_equal apache_result
  end
end

