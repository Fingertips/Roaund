require File.expand_path('../test_helper', __FILE__)

class RoaundTest < ActiveSupport::TestCase
  test "knows whether it should use strict checking" do
    before = Roaund.strict?
    begin
      Roaund.strict = true
      assert Roaund.strict?
      Roaund.strict = false
      assert !Roaund.strict?
    ensure
      Roaund.strict = before
    end
  end
  
  test "generates a nonce" do
    5.times do
      assert_not_equal Roaund.nonce, Roaund.nonce
    end
    assert_match /[\w\d]+/, Roaund.nonce
  end
end

class RoaundAuthorizationTest < ActiveSupport::TestCase
  def setup
    @consumer_secret = 'CFBBlc3za53D8Q0a'
    @token_secret    = 'KDBBlc3za53D8Q0a'
    @params          = {
      'oauth_consumer_key' => 'pviQOhLOahmUQdRC',
      'oauth_token'        => 'deiQOhLOahmUQdRC',
      'oauth_verifier'     => 'cYgD3yVoTW7ofszH'
    }
  end
  
  test "generates a complete PLAINTEXT authorization header with all required params" do
    result = Roaund.parse(Roaund.plaintext_authorization('Robin', @params, @consumer_secret, @token_secret))
    assert_equal 'PLAINTEXT', result['oauth_signature_method']
    assert_equal Roaund::Signature.key(@consumer_secret, @token_secret), result['oauth_signature']
    @params.each do |key, value|
      assert_equal value, result[key]
    end
  end
  
  test "generates a complete HMAC-SHA1 authorization header with all required params" do
    result = Roaund.parse(Roaund.hmac_sha1_authorization('Robin', 'POST', 'http://manage.test/oauth/credentails', @params, @consumer_secret, @token_secret))
    assert_equal 'HMAC-SHA1', result['oauth_signature_method']
    assert_not_nil result['oauth_nonce']
    assert_not_nil result['oauth_timestamp']
    assert_not_nil result['oauth_signature']
    @params.each do |key, value|
      assert_equal value, result[key]
    end
  end
end