require 'test/unit'

require 'rubygems'
gem 'nap'

$:.unshift File.expand_path('../../lib', __FILE__)
require 'roaund'

class Test::Unit::TestCase
  def self._description_to_name(description)
    "test_#{description.gsub(' ', '_')}"
  end
  
  def self.test(description, &block)
    define_method(_description_to_name(description), &block)
  end
end