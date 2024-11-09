module Magic
  module Cards
    FoundryInspector = Creature("Foundry Inspector") do
      cost generic: 3
      type T::Artifact, T::Creature, T::Creatures["Construct"]
      power 3
      toughness 2

      class ReduceManaCost < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          @source = source
          @adjustment = { generic: -1 }
          @applies_to = -> (c) { c.artifact? }
        end
      end

      def static_abilities = [ReduceManaCost]
    end
  end
end
