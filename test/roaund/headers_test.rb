require File.expand_path('../../test_helper', __FILE__)

class Roaund::TestCase < Test::Unit::TestCase
  def self.test(description, &block)
    define_method("test #{description}", &block)
  end
  
  def default_test
  end
end

class Roaund::HeadersTest < Roaund::TestCase
  test "parses key value pairs from the field value of headers" do
    [
      [nil, {}],
      ['', {}],
      ['realm="Robin", oauth_consumer_key="bflQAXXegPPHvmnF", oauth_signature_method="PLAINTEXT", oauth_callback="http://example.com/callback", oauth_signature="ja893SD9%26"', {'realm' => 'Robin', 'oauth_consumer_key' => 'bflQAXXegPPHvmnF', 'oauth_signature_method' => 'PLAINTEXT', 'oauth_signature' => 'ja893SD9&', 'oauth_callback' => 'http://example.com/callback'}],
      [
        %[
        realm="Robin",
        oauth_consumer_key="jd83jd92dhsh93js",
        oauth_signature_method="PLAINTEXT",
        oauth_signature="ja893SD9%26"
        ],
        {'realm' => 'Robin', 'oauth_consumer_key' => 'jd83jd92dhsh93js', 'oauth_signature_method' => 'PLAINTEXT', 'oauth_signature' => 'ja893SD9&'}
      ],
      [
        %[
          realm="Photos",
          oauth_consumer_key="dpf43f3p2l4k3l03",
          oauth_signature_method="HMAC-SHA1",
          oauth_timestamp="137131200",
          oauth_nonce="wIjqoS",
          oauth_callback="http%3A%2F%2Fprinter.example.com%2Fready",
          oauth_signature="74KNZJeDHnMBp0EMJ9ZHt%2FXKycU%3D"
        ],
        {'realm' => 'Photos', 'oauth_consumer_key' => 'dpf43f3p2l4k3l03', 'oauth_signature_method' => 'HMAC-SHA1', 'oauth_timestamp' => '137131200', 'oauth_nonce' => 'wIjqoS', 'oauth_callback' => 'http://printer.example.com/ready', 'oauth_signature' => '74KNZJeDHnMBp0EMJ9ZHt/XKycU=' }
      ]
    ].each do |example, expected|
      assert_equal expected, Roaund::Headers.parse_key_value_pairs(example)
    end
  end
  
  test "parses authorization headers" do
    [
      [nil, {}],
      ['', {}],
      ['OAuth realm="Robin"', {'realm' => 'Robin'}],
      ['Token sdfer24"', {}],
    ].each do |example, expected|
      assert_equal expected, Roaund::Headers.parse_authorization(example)
    end
  end
  
  test "generates an authorization header" do
    assert_equal "OAuth realm=\"Robin\", oauth_verifier=\"hsdfjh234\", oauth_token=\"ds34fe13d\"", Roaund::Headers.generate_authorization('Robin', {'oauth_token' => 'ds34fe13d', 'oauth_verifier' => 'hsdfjh234'})
  end
  
  test "generates key value pairs" do
    assert_equal '', Roaund::Headers.generate_key_value_pairs({})
    assert_equal "oauth_token=\"12\"", Roaund::Headers.generate_key_value_pairs({'oauth_token' => 12})
  end
end