class Roaund
  # Really basic nonce store, does not work properly when used on a server with
  # more than once process because the store isn't shared between instances.
  class NonceStore
    class << self
      attr_accessor :nonces
    end
    self.nonces = []
    
    def self.store(nonce)
      self.nonces << nonce
    end
    
    def self.exist?(nonce)
      nonces.include?(nonce)
    end
  end
end