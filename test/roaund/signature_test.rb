require File.expand_path('../../test_helper', __FILE__)

class Roaund::SignatureTest < ActiveSupport::TestCase
  test "computes the key to use for which to compute the signature" do
    assert_equal 'adpo45&', Roaund::Signature.key('adpo45')
    assert_equal 'adpo45&67dfpe', Roaund::Signature.key('adpo45', '67dfpe')
  end
  
  test "computes a HMAC-SHA1 digest" do
    assert_equal 'tR3+Ty81lMeYAr/Fid0kMTYa/WM=', Roaund::Signature.hmac_sha1('kd94hf93k423kf44&pfkkdhi9sl3r4s00', 'GET&http%3A%2F%2Fphotos.example.net%2Fphotos&file%3Dvacation.jpg%26oauth_consumer_key%3Ddpf43f3p2l4k3l03%26oauth_nonce%3Dkllo9940pd9333jh%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1191242096%26oauth_token%3Dnnch734d00sl2jdk%26oauth_version%3D1.0%26size%3Doriginal')
  end
end

class Roaund::HMACSignatureTest < ActiveSupport::TestCase
  def setup
    @signature = Roaund::Signature.new('POST', 'http://example.com/request', [
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
    ])
  end
  
  test "returns the normalized parameter string" do
    expected = "
      a2=r%20b&a3=2%20q&a3=a&b5=%3D%253D&c%40=&c2=&oauth_consumer_key=9dj
      dj82h48djs9d2&oauth_nonce=7d8f3e4a&oauth_signature_method=HMAC-SHA1
      &oauth_timestamp=137131201&oauth_token=kkk9d7dh3k39sjv7
    ".gsub(/\s/, '')
    assert_equal expected, @signature.normalized_parameter_string
  end
  
  test "computes a signature base string from which to compute the signature" do
    expected = "
      POST&http%3A%2F%2Fexample.com%2Frequest&a2%3Dr%2520b%26a3%3D2%2520q
      %26a3%3Da%26b5%3D%253D%25253D%26c%2540%3D%26c2%3D%26oauth_consumer_
      key%3D9djdj82h48djs9d2%26oauth_nonce%3D7d8f3e4a%26oauth_signature_m
      ethod%3DHMAC-SHA1%26oauth_timestamp%3D137131201%26oauth_token%3Dkkk
      9d7dh3k39sjv7
    ".gsub(/\s/, '')
    assert_equal expected, @signature.signature_base_string
  end
end