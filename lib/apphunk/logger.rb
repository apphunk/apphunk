module Apphunk
  module Logger
    class << self

      def error(message)
        message = "[Apphunk] Error: #{message}"
        case
          when defined?(Rails) && Rails.logger
            Rails.logger.error(message)
          when defined?(RAILS_DEFAULT_LOGGER)
            RAILS_DEFAULT_LOGGER.error(message)
          else
            puts(message)
        end
      end

    end
  end
end
