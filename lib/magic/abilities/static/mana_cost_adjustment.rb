module Magic
  module Abilities
    module Static
      class ManaCostAdjustment < StaticAbility
        attr_reader :source, :adjustment

        def initialize(source:, adjustment:)
          @source = source
          @adjustment = adjustment
        end

        # Subclasses override this (a method, not a stored lambda, so the game stays marshallable).
        def applies_to?(card)
          raise NotImplementedError, "#{self.class} must define applies_to?(card)"
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
