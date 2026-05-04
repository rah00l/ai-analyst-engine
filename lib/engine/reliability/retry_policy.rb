module Engine
  module Reliability

    module RetryPolicy
      MAX_RETRIES = 2
      RETRYABLE = [:TRANSIENT, :RATE_LIMIT].freeze

      def self.retry?(failure, attempt)
        RETRYABLE.include?(failure) && attempt < MAX_RETRIES
      end
    end
  end
end
