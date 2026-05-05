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

  question = request_payload["question"]
  context = request_payload["context"] || {}

  unless question.is_a?(String) && !question.strip.empty?
    halt 422, { error: "question must be a non-empty string" }.to_json
    end

  # result = Engine::Analyzer.analyze(question: body["question"] || body["question"], context: {})
  
result = Engine::Analyzer.analyze(
  question: question,
  context: request_payload["context"] || {}
)


  { result: result }.to_json
end