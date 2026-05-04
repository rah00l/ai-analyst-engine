module Engine
  module Reliability

    module CostGuard
      MAX_CALLS = 3

      def self.start!
        @calls = 0
      end

      def self.record!
        @calls += 1
      end

      def self.exceeded?
        @calls > MAX_CALLS
      end
    end
  end
end
