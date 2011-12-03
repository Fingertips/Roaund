require 'base64'

class Roaund
  class Signature
    attr_accessor :request_method, :base_uri, :parameters
    
    def initialize(request_method, base_uri, parameters)
      @request_method = request_method
      @base_uri = base_uri
      @parameters = parameters
    end
    
    def normalized_request_parameters
      parameters.map do |pair|
        pair.map { |x| Roaund::URI.encode(x) }
      end
    end
    
    def ordered_request_parameters
      normalized_request_parameters.sort_by do |key, value|
        "#{key}#{value}"
      end
    end
    
    def normalized_parameter_string
      ordered_request_parameters.map do |key, value|
        "#{key}=#{value}"
      end.join('&')
    end
    
    def signature_base
      [
        request_method,
        base_uri,
        normalized_parameter_string
      ].compact.map { |x| Roaund::URI.encode(x) }
    end
    
    def signature_base_string
      signature_base.join('&')
    end
        
    def compute_hmac_sha1_signature(consumer_secret, token_secret='')
      Roaund.logger.debug("OAuth: Calculating signature based on `#{consumer_secret}', `#{token_secret}', and #{signature_base_string.inspect}")
      self.class.hmac_sha1(self.class.key(consumer_secret, token_secret), signature_base_string)
    end
    
    def self.key(consumer_secret, token_secret='')
      [consumer_secret, token_secret].map { |x| Roaund::URI.encode(x) }.join('&')
    end
    
    def self.hmac_sha1(key, signature_base_string)
      Base64.encode64(OpenSSL::HMAC.digest('sha1', key, signature_base_string)).strip
    end
  end
end