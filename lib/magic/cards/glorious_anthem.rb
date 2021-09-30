module Magic
  module Cards
    class GloriousAnthem < Card
      NAME = "Glorious Anthem"
      COST = { generic: 1, white: 2}
      TYPE_LINE = "Enchantment"

      def entered_the_battlefield!
        game.battlefield.static_abilities.add(
          Abilities::Static::CreaturesGetBuffed.new(
            source: self,
            power: 1,
            toughness: 1
          )
        )
      end
    end
  end
end
