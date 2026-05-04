module Engine
  class Analyzer
    def self.analyze(text:, context: {})
      analysis_ctx = Context::AnalysisContext.new(
        text: text,
        context: context
      )

      canonical = Intent::Canonicalizer.call(analysis_ctx)
      intent = Intent::IntentResolver.call(canonical)

      concepts = Explanation::ConceptClassifier.call(intent)
      explanation = Explanation::ExplanationBuilder.call(concepts)

      FollowUp::BoundaryResponder.call(explanation)
    end
  end
end