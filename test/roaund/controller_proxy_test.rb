require File.expand_path('../../test_helper', __FILE__)

class Roaund::OAuthInBodyControllerProxyTest < ActiveSupport::TestCase
  def setup
    @env = {}
    @controller = stub
    @request = stub(:env => @env, :form_data? => true)
    @controller.stubs(:request).returns(@request)
    @request.stubs(:query_string).returns('b=2&c=3')
    @request.stubs(:raw_post).returns(Roaund::URI.generate_query([
      ['oauth_consumer_key', '9djdj82h48djs9d2'],
      ['oauth_token', 'kkk9d7dh3k39sjv7'],
      ['oauth_signature', '9YeNFwNavf3xRAZj7zytaezpF5s='],
      ['a', '1']
    ]))
    @proxy = Roaund::ControllerProxy.new(@controller)
  end
  
  test "returns oauth params" do
    assert_equal({
      'oauth_consumer_key' => '9djdj82h48djs9d2',
      'oauth_token' => 'kkk9d7dh3k39sjv7',
      'oauth_signature' => '9YeNFwNavf3xRAZj7zytaezpF5s='
    }, @proxy.oauth_params)
  end
  
  test "does not include the signature in the parameters used for signature computation" do
    assert_equal([
      ["b", "2"],
      ["c", "3"],
      ["oauth_consumer_key", "9djdj82h48djs9d2"],
      ["oauth_token", "kkk9d7dh3k39sjv7"],
      ["a", "1"]
    ], @proxy.parameters)
  end
end

class Roaund::OAuthInQueryControllerProxyTest < ActiveSupport::TestCase
  def setup
    @env = {}
    @controller = stub
    @request = stub(:env => @env, :form_data? => false)
    @controller.stubs(:request).returns(@request)
    @request.stubs(:raw_post).returns('')
    @request.stubs(:query_string).returns(Roaund::URI.generate_query([
      ['oauth_consumer_key', '9djdj82h48djs9d2'],
      ['oauth_token', 'kkk9d7dh3k39sjv7'],
      ['oauth_signature', '9YeNFwNavf3xRAZj7zytaezpF5s='],
      ['a', '1']
    ]))
    @proxy = Roaund::ControllerProxy.new(@controller)
  end
  
  test "returns oauth params" do
    assert_equal({
      'oauth_consumer_key' => '9djdj82h48djs9d2',
      'oauth_token' => 'kkk9d7dh3k39sjv7',
      'oauth_signature' => '9YeNFwNavf3xRAZj7zytaezpF5s='
    }, @proxy.oauth_params)
  end
  
  test "does not include the signature in the parameters used for signature computation" do
    assert_equal([
      ["oauth_consumer_key", "9djdj82h48djs9d2"],
      ["oauth_token", "kkk9d7dh3k39sjv7"],
      ["a", "1"]
    ], @proxy.parameters)
  end
end

class Roaund::BlankControllerProxyTest < ActiveSupport::TestCase
  def setup
    @env = {}
    @controller = stub
    @request = stub(:env => @env, :form_data? => false, :query_string => '', :raw_post => '')
    @controller.stubs(:request).returns(@request)
    
    @proxy = Roaund::ControllerProxy.new(@controller)
  end
  
  test "returns no authorization header from the request" do
    assert_nil(@proxy.authorization)
  end
  
  test "returns blank params" do
    assert_equal({}, @proxy.oauth_params)
  end
  
  test "knowns that OAuth is not present" do
    assert !@proxy.present?
  end
end

class Roaund::PLAINTEXTControllerProxyTest < ActiveSupport::TestCase
  def setup
    @env = {
      "HTTP_AUTHORIZATION" => %[
        OAuth realm="Example",
        oauth_consumer_key="9djdj82h48djs9d2",
        oauth_token="kkk9d7dh3k39sjv7",
        oauth_signature_method="PLAINTEXT",
        oauth_signature="wrong"
      ]
    }
    @controller = stub
    @request = stub(:env => @env, :query_string => '', :form_data? => false)
    @controller.stubs(:request).returns(@request)
    
    @proxy = Roaund::ControllerProxy.new(@controller)
    @proxy.consumer_secret = 'j49sk3j29djd'
    @proxy.token_secret = 'dh893hdasih9'
  end
  
  test "returns the authorization header from the request" do
    assert_equal(@env['HTTP_AUTHORIZATION'], @proxy.authorization)
  end
  
  test "returns parsed OAuth params" do
    assert_equal(Roaund::Headers.parse_authorization(@env['HTTP_AUTHORIZATION']).except('realm'), @proxy.oauth_params)
  end
  
  test "returns all parameters in the request" do
    assert_equal(Set.new([
      ["oauth_signature_method", "PLAINTEXT"],
      ["oauth_consumer_key", "9djdj82h48djs9d2"],
      ["oauth_token", "kkk9d7dh3k39sjv7"]
    ]), Set.new(@proxy.parameters))
  end
  
  test "knows the signature is valid" do
    assert !@proxy.valid_signature?
    @proxy.oauth_params['oauth_signature'] = Roaund::Signature.key(@proxy.consumer_secret, @proxy.token_secret)
    assert @proxy.valid_signature?
  end
  
  test "knows if the request was valid" do
    assert !@proxy.valid?
    @proxy.oauth_params['oauth_signature'] = Roaund::Signature.key(@proxy.consumer_secret, @proxy.token_secret)
    assert @proxy.valid?
  end
  
  test "knowns that OAuth is present" do
    assert @proxy.present?
  end
  
  test "authenticates an oauth token" do
    @proxy.oauth_params['oauth_signature'] = Roaund::Signature.key(@proxy.consumer_secret, @proxy.token_secret)
    entity = stub(
      :secret => @proxy.token_secret,
      :consumer_key_secret => @proxy.consumer_secret
    )
    assert_equal(entity, @proxy.authenticate_token do |oauth_token|
      if oauth_token == @proxy.oauth_params['oauth_token']
        entity
      end
    end)
  end
  
  test "does not authenticate an entity, with wrong credentials" do
    @proxy.oauth_params['oauth_signature'] = Roaund::Signature.key(@proxy.consumer_secret, @proxy.token_secret)
    entity = stub(
      :secret => 'something else',
      :consumer_key_secret => @proxy.consumer_secret
    )
    assert_nil(@proxy.authenticate_token do |oauth_token|
      entity
    end)
  end
  
  test "does not authenticate an entity, when the block doesn't return anything" do
    @proxy.oauth_params['oauth_signature'] = Roaund::Signature.key(@proxy.consumer_secret, @proxy.token_secret)
    assert_nil(@proxy.authenticate_token do |oauth_token|
    end)
  end
end

class Roaund::HMACControllerProxyTest < ActiveSupport::TestCase
  def setup
    @env = {
      "HTTP_AUTHORIZATION" => %[
        OAuth realm="Example",
        oauth_consumer_key="9djdj82h48djs9d2",
        oauth_token="kkk9d7dh3k39sjv7",
        oauth_signature_method="HMAC-SHA1",
        oauth_timestamp="137131201",
        oauth_nonce="7d8f3e4a",
        oauth_signature="r6/TJjbCOr97/+UU0NsvSne7s5g="
      ]
    }
    @controller = stub
    @request = stub(
      :env => @env,
      :request_method => 'POST',
      :scheme => 'http',
      :ssl? => false,
      :host => 'Example.com',
      :port => 80,
      :query_string => 'b5=%3D%253D&a3=a&c%40=&a2=r%20b',
      :form_data? => true,
      :raw_post => "c2&a3=2+q\n",
      :path => '/request'
    )
    @controller.stubs(:request).returns(@request)
    
    @proxy = Roaund::ControllerProxy.new(@controller)
    @proxy.consumer_secret = 'j49sk3j29djd'
    @proxy.token_secret = 'dh893hdasih9'
  end
  
  test "returns the authorization header from the request" do
    assert_equal(@env['HTTP_AUTHORIZATION'], @proxy.authorization)
  end
  
  test "returns parsed OAuth params" do
      assert_equal(Roaund::Headers.parse_authorization(@env['HTTP_AUTHORIZATION']).except('realm'), @proxy.oauth_params)
  end
  
  test "returns the correct base uri from the request" do
    assert_equal('http://example.com/request', @proxy.base_uri)
    @request.stubs(:scheme).returns('HTTPS')
    @request.stubs(:ssl?).returns(true)
    @request.stubs(:port).returns(5050)
    @request.stubs(:host_with_port).returns('Example.com:5050')
    assert_equal 'https://example.com:5050/request', @proxy.base_uri
  end
  
  test "returns all parameters in the request" do
    assert_equal(Set.new([
      ["oauth_nonce", "7d8f3e4a"],
      ["oauth_signature_method", "HMAC-SHA1"],
      ["oauth_timestamp", "137131201"],
      ["oauth_consumer_key", "9djdj82h48djs9d2"],
      ["oauth_token", "kkk9d7dh3k39sjv7"],
      ["b5", "=%3D"],
      ["a3", "a"],
      ["c@", ""],
      ["a2", "r b"],
      ["c2"],
      ["a3", "2 q"]
    ]), Set.new(@proxy.parameters))
  end
  
  test "computes a signature based on the OAuth params" do
    assert_equal 'r6/TJjbCOr97/+UU0NsvSne7s5g=', @proxy.compute_signature
  end
  
  test "knows if the provided signature was correct" do
    assert !@proxy.valid_signature?
    @proxy.oauth_params['oauth_signature'] = 'r6/TJjbCOr97/+UU0NsvSne7s5g='
    assert @proxy.valid_signature?
  end
  
  test "knows if the request was valid" do
    assert !@proxy.valid?
    @proxy.oauth_params['oauth_signature'] = 'r6/TJjbCOr97/+UU0NsvSne7s5g='
    assert @proxy.valid?
  end
  
  test "knowns that OAuth is present" do
    assert @proxy.present?
  end
end

class Roaund::ConsumerControllerProxyTest < ActiveSupport::TestCase
  def setup
    @consumer_key = 'jd83jd92dhsh93js'
    @consumer_secret = 'j49sk3j29djd'
    @env = { "HTTP_AUTHORIZATION" => Roaund.plaintext_authorization('Robin', {
      'oauth_consumer_key' => @consumer_key,
      'oauth_callback' => 'http://example.com/done'
    }, @consumer_secret) }
    @controller = stub
    @request = stub(:env => @env, :query_string => '', :form_data? => false)
    @controller.stubs(:request).returns(@request)
    
    @proxy = Roaund::ControllerProxy.new(@controller)
    @proxy.consumer_secret = @consumer_secret
  end
  
  test "knowns that OAuth is present" do
    assert @proxy.present?
  end
  
  test "authenticates a consumer" do
    entity = stub(
      :key => @consumer_key,
      :secret => @consumer_secret
    )
    assert_equal(entity, @proxy.authenticate_consumer do |consumer_key|
      if consumer_key == @proxy.oauth_params['oauth_consumer_key']
        entity
      end
    end)
  end
  
  test "does not authenticate an entity, with wrong credentials" do
    entity = stub(
      :key => @consumer_key,
      :secret => 'something else'
    )
    assert_nil(@proxy.authenticate_consumer do |consumer_key|
      entity
    end)
  end
  
  test "does not authenticate an entity, when the block doesn't return anything" do
    assert_nil(@proxy.authenticate_consumer do |consumer_key|
    end)
  end
end