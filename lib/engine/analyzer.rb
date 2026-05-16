# frozen_string_literal: true

require "securerandom"

module Engine
  class Analyzer

    # ============================================================
    # Base system prompt — used by grounded controller
    # ============================================================
    BASE_SYSTEM_PROMPT = <<~PROMPT
      You are an AI analyst assistant for a payment reconciliation system.
      You explain system states and errors to accounting teams.
      You do not perform actions. You do not operate the system.
    PROMPT

    # ============================================================
    # Public entry point
    #
    # question: String  — raw user question
    # context:  Hash    — optional session/file state overrides
    #
    # Returns: Hash (ExplanationContract fields, or status/message)
    # ============================================================
    def self.analyze(question:, context: {})
      new(question: question, context: context).call
    end

    # ----------------------------------------------------------
    # Initialiser — wires all components
    # ----------------------------------------------------------
    def initialize(question:, context: {})
      @question = question
      @context  = context

      # v0.10 — session-persistent explanation for follow-up reuse
      # In a stateless HTTP call this starts nil every request.
      # The caller (Sinatra) may pass a prior explanation via context
      # to enable follow-up projection across requests.
      @session_contextual_explanation = context[:prior_explanation]

      # Reliability components
      @ai = Reliability::AiCallBoundary.new(
        api_key: ENV["OPENAI_API_KEY"],
        model:   ENV.fetch("OPENAI_MODEL", "gpt-4o-mini")
      )

      # Grounding components
      @document_adapter    = Grounding::PdfDocumentAdapter.new
      @grounded_controller = Grounding::GroundedExplanationController.new(
        document_adapter: @document_adapter,
        ai: @ai
      )
    end

    # ----------------------------------------------------------
    # call — the full pipeline, matching ai_structured_console.rb
    # ----------------------------------------------------------
    def call
      Reliability::LatencyBudget.start!
      Reliability::CostGuard.start!

      attempt = 0

      loop do
        begin
          Reliability::CostGuard.record!

          result = execute_pipeline

          return Reliability::TrustContract.success(result)

        rescue => e
          failure = Reliability::FailureClassification.classify(e)
          break unless Reliability::RetryPolicy.retry?(failure, attempt)
          break if Reliability::LatencyBudget.exceeded?
          break if Reliability::CostGuard.exceeded?
          attempt += 1
        end
      end

      # Safety fallback — reliability layer exhausted
      Reliability::TrustContract.success(
        Reliability::SafetyFallback.build(:RELIABILITY_EXHAUSTED)
      )
    end

    private

    # ----------------------------------------------------------
    # execute_pipeline
    #
    # Mirrors the exact execution order in ai_structured_console.rb:
    #
    # 1. Infer focus from question
    # 2. Build AnalysisContext
    # 3. Determine blocking condition
    # 4. Check knowledge eligibility
    # 5. If eligible → resolve intent → ExplanationBuilder
    #    If ExplanationBuilder nil → GroundedExplanationController
    # 6. If result nil → follow-up classification and projection
    # 7. If result still nil → NOT_DEFINED (no LLM fallback in engine)
    # ----------------------------------------------------------
    def execute_pipeline
      # --------------------------------------------------------
      # Step 1 — Infer focus from question pattern
      # Phase 5.2 equivalent
      # --------------------------------------------------------
      focus = infer_focus(@question)

      # --------------------------------------------------------
      # Step 2 — Build AnalysisContext with safe defaults
      # Phase 5.4 equivalent
      # --------------------------------------------------------
      file_state = @context[:file_state] || { status: "UNKNOWN", status_category: "UNKNOWN" }

      base_context = Context::AnalysisContext.new(
        session_id:         @context[:session_id]       || SecureRandom.uuid,
        subject:            @context[:subject]          || { type: "payment_file", id: "UNKNOWN" },
        file_state:         file_state,
        current_focus:      focus,
        reasoning_budget:   @context[:reasoning_budget] || { turns_remaining: 2 },
        lifecycle:          @context[:lifecycle]        || { state: :ACTIVE, created_at: Time.now },
        blocking_condition: nil
      )

      # --------------------------------------------------------
      # Step 3 — Determine blocking condition
      # Phase 5.3 equivalent
      # --------------------------------------------------------
      context = Context::AnalysisContext.new(
        **base_context.to_h,
        blocking_condition: determine_blocking(base_context)
      )

      # Inject prior explanation for follow-up reuse
      context.contextual_explanation = @session_contextual_explanation

      # --------------------------------------------------------
      # Step 4 — Knowledge eligibility gate
      # Phase 6.x equivalent — MUST happen before any explanation
      # --------------------------------------------------------
      eligibility = Eligibility::KnowledgeEligibilityGate.evaluate(
        intent: context.current_focus,
        domain: :reconciliation
      )

      result = nil

      # --------------------------------------------------------
      # Step 5 — Grounded execution fork
      # Phase 7.0 equivalent
      #
      # IMPORTANT: System lifecycle statuses (PARTIAL RECONCILED,
      # FULL RECONCILED etc.) bypass grounding — they are answered
      # directly by ExplanationBuilder from the templates.
      # --------------------------------------------------------
      if eligibility.allowed?
        intent = Intent::IntentResolver.new.resolve(@question)

        if intent
          explanation = Explanation::ExplanationBuilder.new.explain(intent.term)

          if explanation
            # System-state explanation — authoritative, no LLM needed
            @session_contextual_explanation = explanation
            context.contextual_explanation  = explanation
            result = explanation
          else
            # Term recognised by intent but not in templates →
            # fall through to handbook-backed grounding
            result = @grounded_controller.explain(
              context:       context,
              eligibility:   eligibility,
              source:        intent.source,
              section:       intent.section,
              version:       intent.version,
              term:          intent.term,
              system_prompt: BASE_SYSTEM_PROMPT,
              user_prompt:   @question
            )
          end
        end
      end

      # --------------------------------------------------------
      # Step 6 — Contextual follow-up reuse
      # v0.10.0 equivalent — READ ONLY, no new LLM calls
      # Only fires when Step 5 produced no result
      # --------------------------------------------------------
      # --------------------------------------------------------
      # Step 5.5 — Direct standalone lifecycle progression
      #
      # Small safe fix:
      # If the user explicitly names a lifecycle state in the
      # question (e.g. "What stage comes after PARSED?"),
      # resolve it directly without requiring prior context.
      #
      # This does NOT change the existing follow-up logic below.
      # --------------------------------------------------------
      if result.nil?
        explicit_state = extract_lifecycle_term_from_input(@question)

        if explicit_state && @question.match?(/comes after|what stage comes after|what comes after|next stage|follows/i)
          result = Lifecycle::LifecycleResolver.new.resolve_next_stage(explicit_state)
        end
      end

      if result.nil? && context.contextual_explanation
        classification = FollowUp::FollowUpClassifier.new.classify(@question)

        result =
          case classification
          when :lifecycle_next
            state = extract_lifecycle_term_from_input(@question) ||
                    extract_lifecycle_term_from_context(context.contextual_explanation)
            Lifecycle::LifecycleResolver.new.resolve_next_stage(state)

          when :out_of_scope
            FollowUp::BoundaryResponder.new.respond

          when :unknown
            nil # falls through to Step 7

          else
            # :blocking_query, :ownership_query, :completion_query, :impact_query
            FollowUp::ProjectionResolver.new.resolve(
              classification,
              context.contextual_explanation
            )
          end
      end

      # --------------------------------------------------------
      # Step 7 — NOT_DEFINED
      #
      # Deliberate engine decision: no LLM fallback here.
      # The engine is deterministic. The demo app layer may add
      # LLM fallback above the engine if desired.
      # --------------------------------------------------------
      result || {
        status:  "NOT_DEFINED",
        message: "This question could not be answered from the reconciliation knowledge base."
      }
    end

    # ----------------------------------------------------------
    # infer_focus — mirrors Phase 5.2 from console exactly
    # ----------------------------------------------------------
    def infer_focus(input)
      case input
      when /what does|what is|meaning of/i
        :status_meaning
      when /what should I do|next|proceed/i
        :next_action
      when /why|error|failed|problem|cause/i
        :error_meaning
      else
        :status_meaning
      end
    end

    # ----------------------------------------------------------
    # determine_blocking — mirrors Phase 5.3 from console exactly
    # ----------------------------------------------------------
    def determine_blocking(context)
      focus  = context.current_focus
      status = context.file_state[:status]

      blocking = { is_blocked: false, reason: nil, responsibility: :NONE }

      if focus == :error_meaning
        case status
        when "MAPPING_ERROR"
          blocking = {
            is_blocked:     true,
            reason:         :INSUFFICIENT_TRANSACTION_CONTEXT,
            responsibility: :USER
          }
        when "PROCESSING"
          blocking = {
            is_blocked:     true,
            reason:         :SYSTEM_STILL_PROCESSING,
            responsibility: :SYSTEM
          }
        end
      end

      blocking
    end

    # ----------------------------------------------------------
    # extract_lifecycle_term_from_input
    # Mirrors the console helper exactly
    # ----------------------------------------------------------
    def extract_lifecycle_term_from_input(input)
      Lifecycle::ReconciliationLifecycleMap::FLOW.find do |status|
        input.upcase.include?(status)
      end
    end

    # ----------------------------------------------------------
    # extract_lifecycle_term_from_context
    # Derives lifecycle term from a stored ExplanationContract
    # ----------------------------------------------------------
    def extract_lifecycle_term_from_context(explanation)
      return nil unless explanation.respond_to?(:concept_type)

      case explanation.concept_type
      when :status_transitional, :status_blocking, :status_terminal
        explanation.respond_to?(:term) ? explanation.term : nil
      end
    end
  end
end