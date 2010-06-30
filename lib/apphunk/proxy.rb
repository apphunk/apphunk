require 'json'

module Apphunk
  module Proxy
    class << self
      
      def send_message_to_apphunkd(message, options)
        if options[:environments] && options[:environment] && !options[:environments].include?(options[:environment])
          return false
        end
        
        payload = prepare_payload(message, options)
        url = generate_api_messages_url(payload[:token])
        return Postbox.post(url, payload) do |result|
          process_response(result)
        end
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
        if result.success == true
          return true
        else
          Apphunk::Logger.error "Could not store message: #{result.response}"
          return false
        end
      end
      
      
      protected

      def generate_api_messages_url(token)
        path = "v1/#{token}/messages"
        "http://api.apphunk.com/#{path}"
      end
 
    end
  end
end
