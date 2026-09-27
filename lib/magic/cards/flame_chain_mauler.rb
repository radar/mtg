module Magic
  module Cards
    FlameChainMauler = Creature("Flame-Chain Mauler") do
      cost generic: 1, red: 1
      creature_type("Elemental Warrior")
      power 2
      toughness 2
    end

    class FlameChainMauler < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}{R}"

        def resolve!
          trigger_effect(:modify_power_toughness, target: source, power: 1, toughness: 0)
          trigger_effect(:grant_keyword, target: source, keyword: :menace)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
