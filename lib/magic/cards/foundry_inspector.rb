module Magic
  module Cards
    FoundryInspector = Creature("Foundry Inspector") do
      cost generic: 3
      type "Artifact Creature -- Constructor"
      power 3
      toughness 2

      def static_abilities
        [
          Abilities::Static::ReduceManaCost.new(
            source: self,
            reduction: { generic: 1 },
            applies_to: -> (c) { c.artifact? }
          )
        ]
      end
    end
  end
end
