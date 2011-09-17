require 'cgi'
require 'rest'

class Roaund
  autoload :Token, 'roaund/token'
  
  class << self
    attr_accessor :temporary_credential_request_url,
                  :resource_owner_authorization_url,
                  :token_request_url
  end
  
  attr_accessor :consumer_key,
                :consumer_token,
                :temporary_token
  
  def initialize(config)
    @consumer_key, @consumer_token = config[:consumer_key], config[:consumer_token]
  end
  
  def initiate
    response = REST.post(self.class.temporary_credential_request_url, nil, {
      'Authorization' => authorization
    })
    if response.ok?
      @temporary_token = Roaund::Token.load(response.body)
      @temporary_token.client = self
    end
  end
  
  def signature_base
    [
      request.method,
      request.host,
      request.path_and_query,
      authorization_as_hash.except('oauth_signature'),
      request.body_params
    ].map { |part| CGI.escape(part) }.join('&')
  end
  
  def authorization_as_hash
    authorization_as_hash = {
      'oauth_consumer_key' => @consumer_key,
      'oauth_signature_method' => 'HMAC-SHA1',
    }
    if temporary_token
      authorization_as_hash['oauth_token'] = temporary_token.token
    end
    authorization_as_hash
  end
  
  def authorization
    "Oauth #{_pairs_to_header_options(authorization_as_hash.merge('Realm' => @realm))}"
  end
  
  def token(params_as_string)
    token = Roaund::Token.new
    token.client = self
    token.parse(params_as_string)
    token
  end
  
  def _pairs_to_header_options(pairs)
    encoded = []; for (key, value) in pairs
      encoded << "#{CGI.escape(key)}=\"#{CGI.escape(value||'')}\""
    end; encoded.join(',')
  end
end