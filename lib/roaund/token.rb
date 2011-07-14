require 'cgi'

class Roaund
  class Token
    attr_accessor :token, :secret, :client
    
    def initialize(token=nil, secret=nil, client=nil)
      @token, @secret, @client = token, secret, client
    end
    
    def load(input)
      params = CGI.parse(input)
      @token, @secret = params['oauth_token'].first, params['oauth_token_secret'].first
    end
    
    def dump
      [
        ['oauth_token',        @token],
        ['oauth_token_secret', @secret]
      ].inject([]) do |parts, (key, value)|
        parts << "#{CGI.escape(key)}=#{CGI.escape(value)}"
      end.join('&')
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