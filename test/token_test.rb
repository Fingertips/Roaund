require File.expand_path('../start', __FILE__)

class TokenTest < Test::Unit::TestCase
  test "initializes" do
    token = Roaund::Token.new
    assert_equal Roaund::Token, token.class
  end
  
  test "loads from and dumps symmetrically" do
    example = Roaund::Token.new('aser', '23po')
    output = Roaund::Token.load(Roaund::Token.dump(example))
    assert_equal Roaund::Token, output.class
    assert_equal example.token, output.token
    assert_equal example.secret, output.secret
  end
end

class ATokenTest < Test::Unit::TestCase
  def setup
    @example = Roaund::Token.new('aser', '23po')
  end
  
  test "loads token and secret from a serialized form" do
    dumped = Roaund::Token.dump(@example)
    
    output = Roaund::Token.new
    output.load(dumped)
    
    assert_equal @example.token, output.token
    assert_equal @example.secret, output.secret
  end
  
  test "dumps token to a serialized form" do
    assert_equal Roaund::Token.dump(@example), @example.dump
  end
  
  test "parses its attributes from serialized GET parameters" do
    example = Roaund::Token.new
    example.parse('oauth_token=requestkey&oauth_token_secret=requestsecret')
    assert_equal 'requestkey', example.token
    assert_equal 'requestsecret', example.secret
  end
end