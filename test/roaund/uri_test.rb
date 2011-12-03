require File.expand_path('../../test_helper', __FILE__)

class Roaund::URITest < ActiveSupport::TestCase
  test "does not escape unreserved characters" do
    unreserved = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a + ["-", ".", "_", "~"]
    unreserved.each do |character|
      assert_equal character, Roaund::URI.encode(character)
    end
  end
  
  test "escapes reserved characters" do
    reserved = ['@', '&', '/']
    reserved.each do |character|
      assert_not_equal character, Roaund::URI.encode(character)
    end
  end
  
  test "properly escapes spaces" do
    assert_equal '%20', Roaund::URI.encode(' ')
  end
  
  test "roundtrips generating and parsing query strings" do
    [
      {},
      {'a' => '1'},
      {'a' => '1', 'a' => '2'}
    ].each do |example|
      assert_equal example, Hash[Roaund::URI.parse_query(Roaund::URI.generate_query(example))]
    end
  end
end