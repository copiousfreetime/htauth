require 'spec_helper'

describe HTAuth::Algorithm do
  it "raises an error if it encouners an unknown algorithm" do
    _ { HTAuth::Algorithm.algorithm_from_name("unknown") }.must_raise(::HTAuth::InvalidAlgorithmError)
  end
end
