require 'spec_helper'
require 'argon2'
require 'htauth/argon2'

describe HTAuth::Argon2 do

  it "decodes the hash back to the original options" do
    hash    = '$argon2id$v=19$m=65536,t=3,p=4$V1ln1M4o1RS7SzWHAtqyWQ$jEHi1Qo2FSBgLAPpOa1mPx6OD/twtjj8M1AlVZwamPg'
    options = HTAuth::Argon2.extract_options_from_existing_password_field(hash)
    _(options).must_equal ::Argon2::Profiles[:rfc_9106_low_memory]
  end

  it "encrypts the same way that argon2 does by default" do
    argon2 = HTAuth::Argon2.new
    hash   = argon2.encode("a secret")
    _(::Argon2::Password.verify_password('a secret', hash)).must_equal true
  end

  it "allow changing the parameters directly" do
    hash    = '$argon2id$v=19$m=262144,t=3,p=4$7DRAuE1yIHPHqISmcyaJTg$M0EErpbxqv8dvrMrQMoGDEA7KQCw67jGdXwtCbRINFs'
    options = HTAuth::Argon2.extract_options_from_existing_password_field(hash)

    options[:m_cost] = 11

    argon2     = HTAuth::Argon2.new(options)
    local_hash = argon2.encode("a secret")
    _(::Argon2::Password.verify_password('a secret', local_hash)).must_equal true
  end
end
