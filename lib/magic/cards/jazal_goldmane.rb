module Magic
  module Cards
    JazalGoldmane = Creature("Jazal Goldmane") do
      cost generic: 2, white: 2
      legendary_creature_type "Cat Warrior"
      keywords :first_strike
      power 4
      toughness 4
    end

    class JazalGoldmane < Creature
      # "{3}{W}{W}: Attacking creatures you control get +X/+X until end of turn, where X is the number of attacking
      # creatures." X counts every attacking creature, whoever controls it, as the ability resolves.
      class PumpAbility < Magic::ActivatedAbility
        costs "{3}{W}{W}"

        def resolve!
          attackers = game.current_turn.attacks.map(&:attacker)
          x = attackers.count
          attackers.select { |attacker| attacker.controller == controller }.each do |attacker|
            attacker.modify_power(x)
            attacker.modify_toughness(x)
          end
        end
      end

      def activated_abilities = [PumpAbility]
    end
  end
end
