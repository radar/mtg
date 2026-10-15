module Magic
  module Cards
    SapphireMedallion = Artifact("Sapphire Medallion") do
      cost generic: 2
    end

    class SapphireMedallion < Artifact
      # "Blue spells you cast cost {1} less to cast."
      class CostReduction < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          super(source:, adjustment: { generic: -1 })
        end

        def applies_to?(card)
          card.is_a?(Magic::Card) && (card.controller || card.owner) == source.controller && card.colors.include?(:blue)
        end
      end

      def static_abilities = [CostReduction]
    end
  end
end
