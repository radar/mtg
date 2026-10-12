module Magic
  module Cards
    StingSlinger = Creature("Sting-Slinger") do
      cost generic: 2, red: 1
      creature_type("Goblin Warrior")
      power 3
      toughness 3
    end

    class StingSlinger < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}{R}, {T}, Blight 1"

        def resolve!
          game.opponents(controller).each { deal_damage(2, to: _1) }
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
