require File.expand_path('../start', __FILE__)

class RoaundTest < Test::Unit::TestCase
  test "initializes" do
    rouand = Roaund.new(:consumer_key => 'sf34', :consumer_token => 'jh34')
    assert_equal Roaund, rouand.class
    assert_equal 'sf34', rouand.consumer_key
    assert_equal 'jh34', rouand.consumer_token
  end
end

class ARoaundTest < Test::Unit::TestCase
  def setup
    @rouand = Roaund.new(:consumer_key => 'sf34', :consumer_token => 'jh34')
  end
  
  test "initiates a an authorization request" do
    REST.stubs(:post).returns(REST::Response.new(200,
      { 'content-type' => 'application/x-www-form-urlencoded' },
      'oauth_token=hh5s93j4hdidpola&oauth_token_secret=hdhd0244k9j7ao03&oauth_callback_confirmed=true')
    )
    @rouand.initiate
    assert @rouand.temporary_token
    assert_equal 'hh5s93j4hdidpola', @rouand.temporary_token.token
    assert_equal 'hdhd0244k9j7ao03', @rouand.temporary_token.secret
  end
end