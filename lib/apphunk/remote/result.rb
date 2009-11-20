module Apphunk
  module Remote
    class Result
      
      attr_accessor :status
      attr_accessor :response
      
      def initialize(opts = {})
        self.status = opts.delete(:status)
        self.response = opts.delete(:response)
      end
      
    end
  end
end