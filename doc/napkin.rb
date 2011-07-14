# Authorizing the consumer for access to the service
roaund = Roaund.new(:consumer_key => "sf34", :consumer_token => 'jh34')
request = roaund.authorize(:callback => 'http://consumer.example.com/complete')
request.redirect_url #=> 'http://provider.example.com/authorize?oauth_token=afer'

# When hit on http://consumer.example.com/complete with a secret token
token = roaund.token('oauth_token=requestkey&oauth_token_secret=requestsecret')
token.key # token.to_s
token.secret

# If you need to store the token for the next request, do it like so:
token.dump # Token.dump(token)
Token.load() # (Token.new.load)

REST.get('http://example.com/members', token.headers.merge('Accept' => 'application/json'))