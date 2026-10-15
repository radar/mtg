module Magic
  module Cards
    RubyMedallion = Artifact("Ruby Medallion") do
      cost generic: 2
    end

    class RubyMedallion < Artifact
      # "Red spells you cast cost {1} less to cast."
      class CostReduction < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          super(source:, adjustment: { generic: -1 })
        end

        def applies_to?(card)
          card.is_a?(Magic::Card) && (card.controller || card.owner) == source.controller && card.colors.include?(:red)
        end
      end

      def static_abilities = [CostReduction]
    end
  end
end
