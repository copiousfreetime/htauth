require 'spec_helper'
require 'htauth/bcrypt'

describe HTAuth::Bcrypt do
  it "encrypts the same way that apache does by default" do
    apache_hash = '$2y$05$X7XeXxp0uAO92AGG2P4/fu0mj7MrRDQnlBTkwZLd9rKiH2OUBb9/K'
    reparsed    = ::BCrypt::Password.new(apache_hash)
    cost        = reparsed.cost

    _(cost).must_equal HTAuth::Bcrypt::DEFAULT_APACHE_COST
    _(reparsed.is_password?("a secret")).must_equal true

    bcrypt      = HTAuth::Bcrypt.new(:cost => cost)
    local_hash  = bcrypt.encode("a secret")

    _(local_hash.is_password?("a secret")).must_equal true
    _(local_hash.cost).must_equal cost
  end

  it "encrypts the same way that apache does with different cost" do
    apache_hash = '$2y$12$O3mBah33UilOkwXrS0kXuOPFBKLBCIp7V.AVvEZQcbnAM5SJLQnfq'
    reparsed    = ::BCrypt::Password.new(apache_hash)
    cost        = reparsed.cost

    _(reparsed.is_password?("a secret")).must_equal true

    bcrypt      = HTAuth::Bcrypt.new(:cost => cost)
    local_hash  = bcrypt.encode("a secret")

    _(local_hash.is_password?("a secret")).must_equal true
    _(local_hash.cost).must_equal cost
  end
end
