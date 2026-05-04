# frozen_string_literal: true

require "sinatra"
require "json"
require_relative "../lib/engine"

set :bind, "0.0.0.0"
set :port, ENV.fetch("PORT", 4567)

post "/analyze" do
  content_type :json

  request_payload =
    begin
      JSON.parse(request.body.read)
    rescue JSON::ParserError
      halt 400, { error: "Invalid JSON payload" }.to_json
    end

  text = request_payload["text"]
  context = request_payload["context"] || {}

  unless text.is_a?(String) && !text.strip.empty?
    halt 422, { error: "text must be a non-empty string" }.to_json
    end

  result = Engine::Analyzer.analyze(text: text, context: context)

  { result: result }.to_json
end