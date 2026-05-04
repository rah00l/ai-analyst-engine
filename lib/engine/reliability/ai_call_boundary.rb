# frozen_string_literal: true

require "json"
require "net/http"
require "uri"


module Engine
  module Reliability
    class AiCallBoundary
      OPENAI_ENDPOINT = "https://api.openai.com/v1/chat/completions"

      def initialize(api_key:, model:)
        @api_key = api_key
        @model = model
      end

      # Pure I/O boundary:
      # - No retries
      # - No fallbacks
      # - May raise normalized technical errors
      def explain(system_prompt:, user_prompt:)  	
      	case user_prompt
      	when /SIMULATE_TIMEOUT/
      	  raise Timeout::Error
      	when /SIMULATE_INVALID_JSON/
      	  raise "INVALID_JSON_OUTPUT"
      	when /SIMULATE_RATE_LIMIT/
      	  raise "OPENAI_ERROR_429"
      	end

        raw = perform_api_call(system_prompt, user_prompt, analysis_context: '')

        normalize_response(raw)
      end

      private

      def perform_api_call(system_prompt, user_prompt, analysis_context: nil)
        uri = URI.parse(OPENAI_ENDPOINT)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(uri)
        request["Authorization"] = "Bearer #{@api_key}"
        request["Content-Type"] = "application/json"

        request.body = {
          model: @model,
          temperature: 0.0,
          response_format: { type: "json_object" },
          messages: [
            { role: "system", content: system_prompt },
            { role: "user", content: user_prompt }
          ]
        }.to_json

        response = http.request(request)
        raise Timeout::Error if response.code.to_i == 504
        raise "OPENAI_ERROR_#{response.code}" unless response.is_a?(Net::HTTPSuccess)

        JSON.parse(response.body)
      end

      def normalize_response(raw)
        content = raw.dig("choices", 0, "message", "content")
        raise "EMPTY_AI_RESPONSE" unless content
        JSON.parse(content)
      rescue JSON::ParserError
        raise "INVALID_JSON_OUTPUT"
      end
    end
  end
end