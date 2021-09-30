module Magic
  module Abilities
    module Static
      class CreaturesGetBuffed
        attr_reader :source, :power, :toughness, :applied_to
        def initialize(source:, power:, toughness:)
          @source = source
          @power = power
          @toughness = toughness
          @applied_to = []
        end

        def applies_to?(card)
          card.creature? && card.controller?(source.controller)
        end

        def applies_while_entering_the_battlefield?
          true
        end

        def apply(card)
          card.power_modifiers << self if power > 0
          card.toughness_modifiers << self if toughness > 0
          @applied_to << card
        end

        def remove
          @applied_to.each do |card|
            card.power_modifiers.delete(self)
            card.toughness_modifiers.delete(self)
          end
        end
      end
    end
  end
end
