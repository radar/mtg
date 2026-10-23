module Magic
  module Cards
    ItThatHeraldsTheEnd = Creature("It That Heralds the End") do
      cost generic: 1, colorless: 1
      creature_type "Eldrazi Drone"
      power 2
      toughness 2
    end

    class ItThatHeraldsTheEnd < Creature
      # "Colorless spells you cast with mana value 7 or greater cost {1} less to cast."
      class ReduceBigColorlessCosts < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          @source = source
          @adjustment = { generic: -1 }
        end

        def applies_to?(card) = card.colorless? && card.cmc >= 7 && card.controller == source.controller
      end

      # "Other colorless creatures you control get +1/+1."
      class ColorlessAnthem < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        applicable_targets { source.controller.creatures.select { _1.colorless? && !_1.equal?(source) } }
      end

      def static_abilities = [ReduceBigColorlessCosts, ColorlessAnthem]
    end
  end
end
