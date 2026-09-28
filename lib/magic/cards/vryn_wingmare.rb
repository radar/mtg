module Magic
  module Cards
    VrynWingmare = Creature("Vryn Wingmare") do
      creature_type("Pegasus")
      cost white: 1, generic: 2
      power 2
      toughness 1
    end

    class VrynWingmare < Creature
      class IncreaseManaCost < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          @source = source
          @adjustment = { generic: 1 }
        end

        def applies_to?(card) = !card.creature?
      end

      def static_abilities = [IncreaseManaCost]
    end
  end
end
