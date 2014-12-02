require "minitest/autorun"

describe BOS do
  it "works" do
    BOS::VERSION.must_equal "0.0.1"
  end
end
