module Magic
  module Cards
    JetMedallion = Artifact("Jet Medallion") do
      cost generic: 2
    end

    class JetMedallion < Artifact
      # "Black spells you cast cost {1} less to cast."
      class CostReduction < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          super(source:, adjustment: { generic: -1 })
        end

        def applies_to?(card)
          card.is_a?(Magic::Card) && (card.controller || card.owner) == source.controller && card.colors.include?(:black)
        end
      end

      def static_abilities = [CostReduction]
    end
  end
end
