require 'rest'

class Roaund
  autoload :Token, 'roaund/token'
  class << self
    attr_accessor :temporary_credential_request_url,
                  :resource_owner_authorization_url,
                  :token_request_url
  end
  
  def token(params_as_string)
    token = Roaund::Token.new
    token.client = self
    token.parse(params_as_string)
    token
  end
end