require File.expand_path('../start', __FILE__)

class RoaundTest < Test::Unit::TestCase
  test "initializes" do
    rouand = Roaund.new
    assert Roaund, rouand.class
  end
end