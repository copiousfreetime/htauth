require 'spec_helper'
require 'htauth/algorithm'

describe HTAuth::Algorithm do
  it "raises an error if it encouners an unknown algorithm" do
    _ { HTAuth::Algorithm.algorithm_from_name("unknown") }.must_raise(::HTAuth::InvalidAlgorithmError)
  end

  it "raises an error if a child class doesn't implement `handles?`" do
    klass = Class.new(HTAuth::Algorithm)
    _ { klass.handles?("foo") }.must_raise(NotImplementedError)
  end
end
