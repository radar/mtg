module Magic
  module Cards
    WarrenSoultrader = Creature("Warren Soultrader") do
      cost generic: 2, black: 1
      creature_type "Zombie Goblin Wizard"
      power 3
      toughness 3
    end

    class WarrenSoultrader < Creature
      # "Pay 1 life, Sacrifice another creature: Create a Treasure token."
      class TreasureAbility < Magic::ActivatedAbility
        costs "Pay 1 life, Sacrifice another creature"

        def resolve!
          create_token(token: Tokens::Treasure)
        end
      end

      def activated_abilities = [TreasureAbility]
    end
  end
end
