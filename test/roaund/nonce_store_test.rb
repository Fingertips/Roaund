require File.expand_path('../../test_helper', __FILE__)

class Roaund::NonceStoreTest < ActiveSupport::TestCase
  test "stores and queries values" do
    nonce = 'ad3435df'
    assert !Roaund::NonceStore.exist?(nonce)
    Roaund::NonceStore.store(nonce)
    assert Roaund::NonceStore.exist?(nonce)
  end
end