require 'cgi'

class Roaund
  class Token
    attr_accessor :token, :secret, :client
    
    def initialize(token=nil, secret=nil, client=nil)
      @token, @secret, @client = token, secret, client
    end
    
    def parse(input)
      params = CGI.parse(input)
      @token, @secret = params['oauth_token'].first, params['oauth_token_secret'].first
    end
    
    def load(input)
      @token, @secret = Marshal.load(input)
    end
    
    def dump
      Marshal.dump([token, secret])
    end
    
    def self.dump(token)
      token.dump
    end
    
    def self.load(input)
      token = new
      token.load(input)
      token
    end
  end
end