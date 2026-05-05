module Engine
  class Analyzer
    def self.analyze(question:, context: {})
      # Step 1 — Build AnalysisContext with safe defaults
      analysis_ctx = Context::AnalysisContext.new(
        session_id: context[:session_id] || "api-session",
        subject: context[:subject] || question,
        file_state: context[:file_state] || :none,
        current_focus: context[:current_focus] || :general,
        reasoning_budget: context[:reasoning_budget] || :standard,
        lifecycle: context[:lifecycle] || :analysis,
        blocking_condition: context[:blocking_condition]
      )

      # Step 2 — Resolve intent from raw question
      intent = Intent::IntentResolver.new.resolve(question)

      # Step 3 — If intent not resolved, return NOT_DEFINED
      unless intent
        return {
          status: "NOT_DEFINED",
          message: "Question not recognised. Try: 'What does PARSED mean?'"
        }
      end

      # Step 4 — Build explanation from canonical term
      explanation = Engine::Explanation::ExplanationBuilder.new.explain(intent.term)

      # Step 5 — Return structured contract or NOT_DEFINED
      if explanation
        explanation.to_h
      else
        {
          status: "NOT_DEFINED",
          message: "Term recognised but not yet modelled: #{intent.term}"
        }
      end
    end
  end
end