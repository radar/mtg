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
        add_effect(
          "DestroyTarget",
          choices: game.battlefield.cards.select { |c| c.artifact? || c.enchantment? || c.land? },
        )

        super
      end
    end
  end
end
