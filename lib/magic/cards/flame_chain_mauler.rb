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
          pump(source, 1, 0)
          give_keyword(source, :menace)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
