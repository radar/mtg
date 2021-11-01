module Magic
  module Cards
    AcidicSlime = Creature("Acidic Slime") do
      cost generic: 3, green: 2
      type "Creature -- Ooze"
      keywords :deathtouch
      power 2
      toughness 2
    end

    class AcidicSlime < Creature
      def entered_the_battlefield!
        game.add_effect(
          Effects::Destroy.new(
            choices: battlefield.cards.select { |c| c.artifact? || c.enchantment? || c.land? },
          )
        )
        super
      end
    end
  end
end
