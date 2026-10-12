module Magic
  module Cards
    TavernSwindler = Creature("Tavern Swindler") do
      cost generic: 1, black: 1
      creature_type "Human Rogue"
      power 2
      toughness 2
    end

    class TavernSwindler < Creature
      # "{T}, Pay 3 life: Flip a coin. If you win the flip, you gain 6 life."
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{T}, Pay 3 life"

        def resolve!
          trigger_effect(:gain_life, life: 6) if controller.flip_coin!
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
