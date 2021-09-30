module Magic
  module Cards
    class FoundryInspector < Creature
      NAME = "Foundry Inspector"
      COST = { generic: 3 }
      TYPE_LINE = "Artifact Creature -- Constructor"

      def entered_the_battlefield!
        game.battlefield.add_static_ability(
          Abilities::Static::ReduceManaCost.new(
            source: self,
            reduction: { colorless: 1 },
            applies_to: -> (c) { c.artifact? }
          )
        )
      end
    end
  end
end
