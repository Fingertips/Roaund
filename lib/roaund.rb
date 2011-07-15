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
    p authorization
    response = REST.post(self.class.temporary_credential_request_url, nil, {
      'Authorization' => authorization
    })
    if response.ok?
      @temporary_token = Roaund::Token.load(response.body)
      @temporary_token.client = self
    end
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
    parts = ["OAuth realm=\"#{@realm}\""]
    authorization_as_hash.each do |key, value|
      parts << "#{CGI.escape(key)}=\"#{CGI.escape(value)}\""
    end
    parts.join(',')
  end
  
  def token(params_as_string)
    token = Roaund::Token.new
    token.client = self
    token.parse(params_as_string)
    token
  end
end