module Apphunk
  module Logger
    class << self
      
      def error(message)
        puts "[Apphunk] Error: #{message}"
      end
      
    end
  end
end