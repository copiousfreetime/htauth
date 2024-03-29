require 'spec_helper'

describe HTAuth::DigestEntry do
  before(:each) do
    @alice = HTAuth::DigestEntry.new("alice", "htauth")
    @bob   = HTAuth::DigestEntry.new("bob", "htauth", "b secret")
  end

  it "initializes with a user and realm" do
    _(@alice.user).must_equal "alice"
    _(@alice.realm).must_equal "htauth"
  end

  it "has the correct digest for a password" do
    @alice.password = "digit"
    _(@alice.digest).must_equal "4ed9e5744c6747af8f292d28afd6372e"
  end

  it "returns username:realm for a key" do
    _(@alice.key).must_equal "alice:htauth"
  end

  it "checks the password correctly" do
    _(@bob.authenticated?("b secret")).must_equal true
  end

  it "formats correctly when put to a string" do
    _(@bob.to_s).must_equal "bob:htauth:fcbeab6821d2ab3b00934c958db0fd1e"
  end

  it "parses an input line" do
    @bob_new = HTAuth::DigestEntry.from_line("bob:htauth:fcbeab6821d2ab3b00934c958db0fd1e")
    _(@bob.user).must_equal @bob_new.user
    _(@bob.digest).must_equal @bob_new.digest
    _(@bob.realm).must_equal @bob_new.realm
  end

  it "knows if an input line is a possible entry and raises an exception" do
    _ { HTAuth::DigestEntry.is_entry!("#stuff") }.must_raise(HTAuth::InvalidDigestEntry)
    _ { HTAuth::DigestEntry.is_entry!("this:that:other:stuff") }.must_raise(HTAuth::InvalidDigestEntry)
    _ { HTAuth::DigestEntry.is_entry!("this:that:other") }.must_raise(HTAuth::InvalidDigestEntry)
    _ { HTAuth::DigestEntry.is_entry!("this:that:0a90549e8ffb2dd62f98252a95d88xyz") }.must_raise(HTAuth::InvalidDigestEntry)
  end

  it "knows if an input line is a possible entry and returns false" do
    _(HTAuth::DigestEntry.is_entry?("#stuff")).must_equal false
    _(HTAuth::DigestEntry.is_entry?("this:that:other:stuff")).must_equal false 
    _(HTAuth::DigestEntry.is_entry?("this:that:other")).must_equal false 
    _(HTAuth::DigestEntry.is_entry?("this:that:0a90549e8ffb2dd62f98252a95d88xyz")).must_equal false
  end

  it "knows if an input line is a possible entry and returns true" do
    _(HTAuth::DigestEntry.is_entry?("bob:htauth:0a90549e8ffb2dd62f98252a95d88697")).must_equal true
  end

  it "duplicates itself" do
    _(@alice.dup.to_s).must_equal @alice.to_s
  end
end
