module Magic
  module Abilities
    module Static
      class ManaCostAdjustment < StaticAbility
        attr_reader :source, :adjustment, :applies_to
        def initialize(source:, adjustment:, applies_to:)
          @source = source
          @adjustment = adjustment
          @applies_to = applies_to
        end

        def applies_to?(card)
          applies_to.call(card)
        end

        def applies_while_entering_the_battlefield?
          false
        end

        def apply(cost)
          cost.adjusted_by(adjustment)
        end
      end
    end
  end
end
