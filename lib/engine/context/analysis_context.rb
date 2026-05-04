module Engine
  module Context
    class AnalysisContext
      attr_reader :session_id,
                  :subject,
                  :file_state,
                  :current_focus,
                  :reasoning_budget,
                  :lifecycle,
                  :blocking_condition

      attr_accessor :contextual_explanation

      def initialize(
        session_id:,
        subject:,
        file_state:,
        current_focus:,
        reasoning_budget:,
        lifecycle:,
        blocking_condition:
      )
        @session_id = session_id
        @subject = subject
        @file_state = file_state
        @current_focus = current_focus
        @reasoning_budget = reasoning_budget
        @lifecycle = lifecycle
        @blocking_condition = blocking_condition

        # v0.10 contextual reuse
        @contextual_explanation = nil
      end

      def to_h
        {
          session_id: @session_id,
          subject: @subject,
          file_state: @file_state,
          current_focus: @current_focus,
          reasoning_budget: @reasoning_budget,
          lifecycle: @lifecycle,
          blocking_condition: @blocking_condition
        }
      end
    end
  end
end