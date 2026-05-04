module Engine
  module Reliability
# failure_classification.rb

    module FailureClassification
      def self.classify(error)
        case error.message
        when /TIMEOUT/
          :TRANSIENT
        when /429/
          :RATE_LIMIT
        when /INVALID_JSON/
          :INVALID_OUTPUT
        else
          :TERMINAL
        end
      end
    end
  end
end
