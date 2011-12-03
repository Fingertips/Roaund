require 'test/unit'

require 'set'

require 'rubygems'
require 'active_support'
require 'active_support/core_ext'
require 'active_support/test_case'

$:.unshift(File.expand_path('../../lib', __FILE__))
require 'roaund'

$:.unshift(File.expand_path('../', __FILE__))
class ActiveSupport::TestCase
  require 'test_helper/collector'
end