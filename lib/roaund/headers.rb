require 'cgi'

class Roaund
  class Headers
    def self.parse_key_value_pairs(data)
      values = {}
      for key, value in data.to_s.scan(/([\w_]+)="(.+?)"/)
        values[key] = Roaund::URI.decode(value)
      end; values
    end
    
    def self.parse_authorization(authorization)
      return {} if authorization.nil? || authorization.strip == ''
      scheme, data = authorization.split(' ', 2)
      (scheme == 'OAuth') ? self.parse_key_value_pairs(data) : {}
    end
    
    def self.generate_key_value_pairs(params)
      out = []
      params.each do |key, value|
        out << "#{key}=\"#{Roaund::URI.encode(value)}\""
      end
      out.join(', ')
    end
    
    def self.generate_authorization(realm, params)
      "OAuth realm=\"#{realm}\", #{generate_key_value_pairs(params)}"
    end
  end
end