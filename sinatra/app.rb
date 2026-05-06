# frozen_string_literal: true

require "sinatra"
require "json"
require_relative "../lib/engine"

set :bind, "0.0.0.0"
set :port, ENV.fetch("PORT", 4567)

SESSION_STORE = {} # in-memory, keyed by session_id

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

  session_id = request_payload["session_id"] || SecureRandom.uuid

  unless question.is_a?(String) && !question.strip.empty?
    halt 422, { error: "question must be a non-empty string" }.to_json
    end

  # Retrieve prior explanation for this session
  prior = SESSION_STORE[session_id]
  
  result = Engine::Analyzer.analyze(
  question: question,
  context: {
    session_id: session_id,
    prior_explanation: prior
  }
)
  # Store the new explanation if it was authoritative
  if result.dig(:result).is_a?(Engine::Explanation::ExplanationContract)
    SESSION_STORE[session_id] = result[:result]
  end


answer =
  if result[:result].respond_to?(:to_h)
    result.merge(result: result[:result].to_h)
  else
    result
  end

  { result: answer }.to_json
end