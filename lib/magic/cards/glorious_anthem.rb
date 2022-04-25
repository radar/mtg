module Magic
  module Cards
    class GloriousAnthem < Card
      NAME = "Glorious Anthem"
      COST = { generic: 1, white: 2}
      TYPE_LINE = "Enchantment"

      def static_abilities
        [
          Abilities::Static::CreaturesGetBuffed.new(
            source: self,
            power: 1,
            toughness: 1,
            applicable_targets: -> { battlefield.creatures.controlled_by(controller) }
          )
        ]
      end
    end
  end
end
