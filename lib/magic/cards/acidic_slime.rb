module Magic
  module Cards
    class AcidicSlime < Creature
      NAME = "Acidic Slime"
      COST = { generic: 3, green: 2 }
      TYPE_LINE = "Creature -- Ooze"
      KEYWORDS = [Keywords::DEATHTOUCH]

      def entered_the_battlefield!
        game.add_effect(
          Effects::Destroy.new(
            choices: game.battlefield.cards.select { |c| c.type?("Artifact") || c.type?("Enchantment") || c.type?("Land") },
          )
        )
        super
      end
    end
  end
end
