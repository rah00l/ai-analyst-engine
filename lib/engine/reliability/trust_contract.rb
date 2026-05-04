module Engine
  module Reliability

    module TrustContract
      def self.success(payload)
        { status: "SUCCESS", result: payload }
      end

      def self.failure(payload)
        { status: "ERROR", error: payload }
      end
    end
  end
end