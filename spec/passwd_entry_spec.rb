require 'spec_helper'
require 'htauth/passwd_entry'

describe HTAuth::PasswdEntry do
  before(:each) do
    @alice = HTAuth::PasswdEntry.new("alice", "a secret", "crypt", { :salt => "mD" })
    @bob   = HTAuth::PasswdEntry.new("bob", "b secret", "crypt", { :salt => "b8"})
    @salt  = "lo1tk/.."
  end

  it "initializes with a user and realm" do
    _(@alice.user).must_equal "alice"
  end

  it "has the correct crypt password" do
    @alice.password = "a secret"
    _(@alice.digest).must_equal "mDwdZuXalQ5zk"
  end

  it "encrypts correctly for md5" do
    bob = HTAuth::PasswdEntry.new("bob", "b secret", "md5", { :salt => @salt })
    _(bob.digest).must_equal "$apr1$lo1tk/..$CarApvZPee0F6Wj1U0GxZ1"
  end

  it "encrypts correctly for sha1" do
    bob = HTAuth::PasswdEntry.new("bob", "b secret", "sha1", { :salt => @salt })
    _(bob.digest).must_equal "{SHA}b/tjGXbX80MEKVnF200S43ca4hY="
  end

  it "encrypts correctly for plaintext" do
    bob = HTAuth::PasswdEntry.new("bob", "b secret", "plaintext", { :salt => @salt })
    _(bob.digest).must_equal "b secret"
  end

  it "encrypts with crypt as a default, when parsed from crypt()'d line" do
    bob2 = HTAuth::PasswdEntry.from_line(@bob.to_s)
    _(bob2.algorithm).must_be_instance_of(HTAuth::Crypt)
    bob2.password = "another secret"
    _(bob2.algorithm).must_be_instance_of(HTAuth::Crypt)
  end

  it "encrypts with crypt as a default, when parsed from plaintext line" do
    p = HTAuth::PasswdEntry.new('paul', 'p secret', 'plaintext')
    p2 = HTAuth::PasswdEntry.from_line(p.to_s)
    _(p2.algorithm).must_be_instance_of(HTAuth::Plaintext)
    p2.password = "another secret"
    _(p2.algorithm).must_be_instance_of(HTAuth::Crypt)
  end

  it "encrypts with md5 as default, when parsed from an md5 line" do
    m = HTAuth::PasswdEntry.new("mary", "m secret", "md5") 
    m2 = HTAuth::PasswdEntry.from_line(m.to_s)
    _(m2.algorithm).must_be_instance_of(HTAuth::Md5)
  end

  it "encrypts with sha1 as default, when parsed from an sha1 line" do
    s = HTAuth::PasswdEntry.new("steve", "s secret", "sha1") 
    s2 = HTAuth::PasswdEntry.from_line(s.to_s)
    _(s2.algorithm).must_be_instance_of(HTAuth::Sha1)
  end

  it "encrypts with bcrypt as default when parsed from a bcrypt line" do
    b = HTAuth::PasswdEntry.new("brenda", "b secret", "bcrypt")
    b2 = HTAuth::PasswdEntry.from_line(b.to_s)
    _(b2.algorithm).must_be_instance_of(HTAuth::Bcrypt)
  end

  it "determins the algorithm to be crypt when checking a password" do
    bob2 = HTAuth::PasswdEntry.from_line(@bob.to_s)
    _(bob2.algorithm).must_be_instance_of(HTAuth::Crypt)
    _(bob2.authenticated?("b secret")).must_equal true
    _(bob2.algorithm).must_be_instance_of(HTAuth::Crypt)
  end

  it "determins the algorithm to be plain when checking a password" do
    bob2 = HTAuth::PasswdEntry.from_line("bob:b secret")
    _(bob2.algorithm).must_be_instance_of(HTAuth::Plaintext)
    _(bob2.authenticated?("b secret")).must_equal true
    _(bob2.algorithm).must_be_instance_of(HTAuth::Plaintext)
  end

  it "authenticates correctly against md5" do
    m = HTAuth::PasswdEntry.new("mary", "m secret", "md5") 
    m2 = HTAuth::PasswdEntry.from_line(m.to_s)
    _(m2.authenticated?("m secret")).must_equal true
  end

  it "authenticates correctly against sha1" do
    s = HTAuth::PasswdEntry.new("steve", "s secret", "sha1") 
    s2 = HTAuth::PasswdEntry.from_line(s.to_s)
    _(s2.authenticated?("s secret")).must_equal true
  end

  it "authenticates correctly against bcrypt" do
    s = HTAuth::PasswdEntry.new("brenda", "b secret", "bcrypt")
    s2 = HTAuth::PasswdEntry.from_line(s.to_s)
    _(s2.authenticated?("b secret")).must_equal true
  end

  it "can update the cost of an entry after initialization before encoding password" do
    s = HTAuth::PasswdEntry.new("brenda", "b secret", "bcrypt")
    _(s.algorithm.cost).must_equal(::HTAuth::Bcrypt::DEFAULT_APACHE_COST)

    s2 = HTAuth::PasswdEntry.from_line(s.to_s)
    s2.algorithm_args = { :cost => 12 }
    s2.password = "b secret" # forces recalculation

    _(s2.algorithm.cost).must_equal(12)
  end

  it "raises an error if assinging an invalid algorithm" do
    b = HTAuth::PasswdEntry.new("brenda", "b secret", "bcrypt")
    _ { b.algorithm = 42 }.must_raise(HTAuth::InvalidAlgorithmError)
  end

  it "returns username for a key" do
    _(@alice.key).must_equal "alice"
  end

  it "checks the password correctly" do
    _(@bob.authenticated?("b secret")).must_equal true
  end

  it "formats correctly when put to a string" do
    _(@bob.to_s).must_equal "bob:b8Ml4Jp9I0N8E"
  end

  it "parses an input line" do
    @bob_new = HTAuth::PasswdEntry.from_line("bob:b8Ml4Jp9I0N8E")
    _(@bob.user).must_equal @bob_new.user
    _(@bob.digest).must_equal @bob_new.digest
  end

  it "knows if an input line is a possible entry and raises an exception" do
    _ { HTAuth::PasswdEntry.is_entry!("#stuff") }.must_raise(HTAuth::InvalidPasswdEntry)
    _ { HTAuth::PasswdEntry.is_entry!("this:that:other:stuff") }.must_raise(HTAuth::InvalidPasswdEntry)
    _ { HTAuth::PasswdEntry.is_entry!("this:that:other") }.must_raise(HTAuth::InvalidPasswdEntry)
    _ { HTAuth::PasswdEntry.is_entry!("this:that:0a90549e8ffb2dd62f98252a95d88xyz") }.must_raise(HTAuth::InvalidPasswdEntry)
  end

  it "knows if an input line is a possible entry and returns false" do
    _(HTAuth::PasswdEntry.is_entry?("#stuff")).must_equal false
    _(HTAuth::PasswdEntry.is_entry?("this:that:other:stuff")).must_equal false 
    _(HTAuth::PasswdEntry.is_entry?("this:that:other")).must_equal false 
    _(HTAuth::PasswdEntry.is_entry?("this:that:0a90549e8ffb2dd62f98252a95d88xyz")).must_equal false
  end

  it "knows if an input line is a possible entry and returns true" do
    _(HTAuth::PasswdEntry.is_entry?("bob:irRm0g.SDfCyI")).must_equal true
    _(HTAuth::PasswdEntry.is_entry?("bob:b secreat")).must_equal true
    _(HTAuth::PasswdEntry.is_entry?("bob:{SHA}b/tjGXbX80MEKVnF200S43ca4hY=")).must_equal true
    _(HTAuth::PasswdEntry.is_entry?("bob:$apr1$lo1tk/..$CarApvZPee0F6Wj1U0GxZ1")).must_equal true
    _(HTAuth::PasswdEntry.is_entry?("bob:$2y$05$ts3k1r.t0Cne6j6DLt0/SepT5X4qthDFEdfqHBBMO5MhqzyMz34j2")).must_equal true
  end

  it "duplicates itself" do
    _(@alice.dup.to_s).must_equal @alice.to_s
  end
end
