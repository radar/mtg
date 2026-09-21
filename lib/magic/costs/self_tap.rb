module Magic
  module Costs
    class SelfTap
      attr_reader :permanent

      def initialize(permanent)
        @permanent = permanent
      end

      def pay
        raise "Cannot pay self tap cost for #{permanent.name}" unless can_pay?(permanent.controller)

        permanent.tap!
      end

      def can_pay?(_player)
        permanent.untapped? && (!permanent.creature? || permanent.haste? || !permanent.summoning_sick?)
      end

      def finalize!(_player)
      end
    end
  end
end
