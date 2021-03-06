module Magic
  module Cards
    class FoundryInspector < Creature
      NAME = "Foundry Inspector"
      COST = { generic: 3 }
      TYPE_LINE = "Artifact Creature -- Constructor"

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
