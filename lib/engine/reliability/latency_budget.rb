module Engine
  module Reliability

    module LatencyBudget
      MAX_SECONDS = 8

      def self.start!
        @start = Time.now
      end

      def self.exceeded?
        Time.now - @start >= MAX_SECONDS
      end
    end
  end
end
