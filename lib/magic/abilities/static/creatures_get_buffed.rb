module Magic
  module Abilities
    module Static
      class CreaturesGetBuffed
        attr_reader :source, :power, :toughness
        def initialize(source:, power:, toughness:)
          @source = source
          @power = power
          @toughness = toughness
        end

        def modifies_power?
          true
        end

        def modifies_toughness?
          true
        end

        def applies_to?(card)
          card.creature? && card.controller?(source.controller)
        end
      end
    end
  end
end
