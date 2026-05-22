# frozen_string_literal: true

require "sinatra"
require "json"
require "logger"
require_relative "../lib/engine"

# Production-ready Sinatra application with health checks and error handling
class AnalystEngine < Sinatra::Base
  # Logging configuration
  configure do
    enable :logging
    set :dump_errors, false
    set :logger, Logger.new($stdout)
  end

  set :bind, "0.0.0.0"
  set :port, ENV.fetch("PORT", 4567)

  SESSION_STORE = {} # in-memory, keyed by session_id

  # ========================================
  # HEALTH CHECKS & MONITORING ENDPOINTS
  # ========================================

  # Health endpoint - CRITICAL for Railway deployment
  get "/health" do
    content_type :json
    logger.info "Health check requested"
    {
      status: "ok",
      service: "ai-analyst-engine",
      timestamp: Time.now.iso8601,
      version: "1.0.0",
      environment: ENV["RACK_ENV"] || "development"
    }.to_json
  end

  # Readiness endpoint - checks if service is ready for requests
  get "/ready" do
    content_type :json
    logger.info "Readiness check requested"
    {
      ready: true,
      timestamp: Time.now.iso8601
    }.to_json
  end

  # Info endpoint - service information
  get "/info" do
    content_type :json
    {
      service: "AI Analyst Engine",
      version: "1.0.0",
      timestamp: Time.now.iso8601
    }.to_json
  end

  # ========================================
  # MAIN ANALYSIS ENDPOINT
  # ========================================

  post "/analyze" do
    content_type :json

    request_payload =
      begin
        JSON.parse(request.body.read)
      rescue JSON::ParserError
        halt 400, { error: "Invalid JSON payload", code: "PARSE_ERROR" }.to_json
      end

    question = request_payload["question"]
    context = request_payload["context"] || {}

    session_id = request_payload["session_id"] || SecureRandom.uuid

    unless question.is_a?(String) && !question.strip.empty?
      halt 422, { error: "question is required", code: "INVALID_INPUT" }.to_json
    end

    logger.info "Analyzing: #{question[0..50]}..." # Log first 50 chars for debugging

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

  # ========================================
  # ERROR HANDLERS
  # ========================================

  # Handle JSON parsing errors
  error JSON::ParserError do
    status 400
    content_type :json
    {
      error: "Invalid JSON",
      code: "PARSE_ERROR"
    }.to_json
  end

  # Handle standard errors
  error StandardError do
    status 500
    content_type :json
    logger.error "Error: #{env['sinatra.error'].message}"
    {
      error: "Internal server error",
      code: "SERVER_ERROR"
    }.to_json
  end

  # Handle 404 Not Found
  error 404 do
    status 404
    content_type :json
    {
      error: "Endpoint not found",
      code: "NOT_FOUND",
      path: request.path
    }.to_json
  end

  # Handle 405 Method Not Allowed
  error 405 do
    status 405
    content_type :json
    {
      error: "Method not allowed",
      code: "METHOD_NOT_ALLOWED",
      method: request.request_method
    }.to_json
  end

  # Handle all other errors
  error do
    status 500
    content_type :json
    logger.error "Unhandled error: #{env['sinatra.error']&.message}"
    {
      error: "Server error",
      code: "SERVER_ERROR"
    }.to_json
  end
end
