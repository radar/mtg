module Magic
  module Cards
    FoundryInspector = Creature("Foundry Inspector") do
      cost generic: 3
      type T::Artifact, T::Creature, T::Creatures["Construct"]
      power 3
      toughness 2
    end

    class FoundryInspector < Creature
      class ReduceManaCost < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          @source = source
          @adjustment = { generic: -1 }
        end

        def applies_to?(card) = card.artifact?
      end

      def static_abilities = [ReduceManaCost]
    end
  end
end
