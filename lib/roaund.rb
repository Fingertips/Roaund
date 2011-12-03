require 'logger'
require 'roaund/errors'

class Roaund
  autoload :ControllerProxy, 'roaund/controller_proxy'
  autoload :Headers,         'roaund/headers'
  autoload :Lint,            'roaund/lint'
  autoload :Proxy,           'roaund/proxy'
  autoload :Signature,       'roaund/signature'
  autoload :NonceStore,      'roaund/nonce_store'
  autoload :URI,             'roaund/uri'
  
  class << self
    # A logger instance
    attr_accessor :logger
    
    # An object responding to #store(nonce) and #exist?(none)
    # to test if nonces passed by clients are unqiue.
    attr_accessor :nonce_store
    
    # When using strict mode OAuth requests are checked more
    # strictly. For example: nonce and timestamp values have
    # to be valid.
    attr_writer :strict
  end
  
  self.logger = Logger.new($stderr)
  self.logger.level = Logger::DEBUG
  self.strict = false
  self.nonce_store = Roaund::NonceStore
  
  # Returns true when running in strict mode
  def self.strict?
    @strict
  end
  
  def self.nonce
    Digest::SHA1.hexdigest(
      [Time.now, Process.pid, object_id, rand].join('---')
    ).to_i(16).to_s(36)
  end
  
  def self.plaintext_authorization(realm, params, consumer_secret, token_secret='')
    params = {
      'oauth_signature_method' => 'PLAINTEXT',
      'oauth_signature' => Roaund::Signature.key(consumer_secret, token_secret)
    }.merge(params)
    Roaund::Headers.generate_authorization(realm, params)
  end
  
  def self.hmac_sha1_authorization(realm, request_method, url, params, consumer_secret, token_secret='')
    params = {
      'oauth_signature_method' => 'HMAC-SHA1',
      'oauth_timestamp' => Time.now.to_i.to_s,
      'oauth_nonce' => nonce
    }.merge(params)
    signature = Roaund::Signature.new(request_method, url, params)
    params['oauth_signature'] = signature.compute_hmac_sha1_signature(consumer_secret, token_secret)
    Roaund::Headers.generate_authorization(realm, params)
  end
  
  def self.parse(authorization)
    Roaund::Headers.parse_authorization(authorization)
  end
end