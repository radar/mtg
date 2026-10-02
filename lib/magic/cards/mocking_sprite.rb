module Magic
  module Cards
    MockingSprite = Creature("Mocking Sprite") do
      cost generic: 2, blue: 1
      creature_type("Faerie Rogue")
      keywords :flying
      power 2
      toughness 1
    end

    class MockingSprite < Creature
      class CostReduction < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          super(source:, adjustment: { generic: -1 })
        end

        def applies_to?(card)
          (card.controller || card.owner) == source.controller && (card.type?("Instant") || card.type?("Sorcery"))
        end
      end

      def static_abilities = [CostReduction]
    end
  end
end
