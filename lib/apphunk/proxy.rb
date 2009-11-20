require 'json'
require 'ostruct'

module Apphunk
  module Proxy
    class << self
      
      PROXY_API_URL = "http://127.0.0.1:8212/api/messages"
      
      def send_message_to_apphunkd(message, options)
        payload = prepare_payload(message, options)
        result = Apphunk::Remote.post(PROXY_API_URL, payload, 3)
        return process_response(result)
      end

      def prepare_payload(message, options)
        {
          :message      => message,
          :token        => options[:token],
          :environment  => options[:environment],
          :tags         => options[:tags],
          :trails       => (options[:trails].to_json if options[:trails])
        }
      end
      
      def process_response(result)
        if result.status == :ok
          if result.response.code == '201'
            return true
          else
            Apphunk::Logger.error "The Apphunkd Proxy couldn't store the message: #{result.response.code} / #{result.response.body}"
            return false
          end
        else
          Apphunk::Logger.error "Connection Error: Could not get a response from Apphunkd in time"
          return false
        end
      end
      
    end
  end
end