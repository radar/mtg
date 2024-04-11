module Magic
  module Abilities
    module Static
      class PowerAndToughnessModification < StaticAbility
        attr_reader :source, :power, :toughness, :applicable_targets
        def initialize(source:, power:, toughness:, applicable_targets:)
          @source = source
          @power = power
          @toughness = toughness
          @applicable_targets = applicable_targets
          @applied_to = []
        end

        def applies_to?(target)
          applicable_targets.include?(target)
        end
      end
    end
  end
end
