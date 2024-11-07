module Magic
  module Permanents
    class Modification
      def initialize(until_eot: true)
        @until_eot = until_eot
      end

      def type_grants
        []
      end

      def power_modification
        @power_modification || 0
      end

      def toughness_modification
        @toughness_modification || 0
      end

      def until_eot?
        @until_eot
      end
    end
  end
end
