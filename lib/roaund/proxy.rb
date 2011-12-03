class Roaund
  module Proxy
    def oauth
      @oauth ||= Roaund::ControllerProxy.new(self)
    end
  end
end