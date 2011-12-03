require File.expand_path('../../test_helper', __FILE__)

class TokenLintable
  Roaund::Lint::REQUIRED_TOKEN_METHODS.each do |method|
    define_method(method) {}
  end
end

class ConsumerLintable
  Roaund::Lint::REQUIRED_CONSUMER_METHODS.each do |method|
    define_method(method) {}
  end
end


class Roaund::LintTest < ActiveSupport::TestCase
  test "lints token when all the methods are supported" do
    assert Roaund::Lint.token_model(TokenLintable.new)
  end
  
  test "does not lint token when something is wrong" do
    stderr = $stderr
    begin
      $stderr = Collector.new
      assert !Roaund::Lint.token_model(Object.new)
      assert $stderr.written.join("\n").include?('secret')
    ensure
      $stderr = stderr
    end
  end
  
  test "lints consumer when all the methods are supported" do
    assert Roaund::Lint.consumer_model(ConsumerLintable.new)
  end
  
  test "does not lint consumer when something is wrong" do
    stderr = $stderr
    begin
      $stderr = Collector.new
      assert !Roaund::Lint.consumer_model(Object.new)
      assert $stderr.written.join("\n").include?('secret')
    ensure
      $stderr = stderr
    end
  end
end