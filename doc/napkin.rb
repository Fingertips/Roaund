# Getting an authentication token for a single request or limited amount of requests.
request = Roaund.request_token(:consumer_key => "sf34", :consumer_token => 'jh34', :send_to_url => 'http://consumer.example.com/token')
request.redirect_url = 'http://provider.example.com/oauth'

# When hit on /token:
token = Roaund::Token.with_params('oauth_token=requestkey&oauth_token_secret=requestsecret')
token.key # token.to_s
token.secret

# Getting an authentication token for access over a longer period of time.
request = Roaund.access_token(:consumer_key => "sf34", :consumer_token => 'jh34')
# Rest is the same as with request token

RESTWithOauth.get(token, 'http://example.com/members.json', { 'Accept' => 'application/json' })