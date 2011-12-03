class Roaund
  class Lint
    REQUIRED_TOKEN_METHODS = %w(secret consumer_key_secret)
    def self.token_model(instance)
      REQUIRED_TOKEN_METHODS.each do |method|
        begin
          instance.send(method)
        rescue NoMethodError
          $stderr.puts("[!] #{instance} does not respond to #{method}")
          return false
        end
      end; true
    end
    
    REQUIRED_CONSUMER_METHODS = %w(secret)
    def self.consumer_model(instance)
      REQUIRED_CONSUMER_METHODS.each do |method|
        begin
          instance.send(method)
        rescue NoMethodError
          $stderr.puts("[!] #{instance} does not respond to #{method}")
          return false
        end
      end; true
    end
  end
end