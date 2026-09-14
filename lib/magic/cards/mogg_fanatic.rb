module Magic
  module Cards
    MoggFanatic = Creature("Mogg Fanatic") do
      cost red: 1
      creature_type "Goblin"
      power 1
      toughness 1
    end

    class MoggFanatic < Creature
      class SacrificeAbility < Magic::ActivatedAbility
        costs "Sacrifice {this}"

        def single_target?
          true
        end

        def target_choices
          game.any_target
        end

        def resolve!(target:)
          trigger_effect(:deal_damage, damage: 1, target: target)
        end
      end

      def activated_abilities = [SacrificeAbility]
    end
  end
end
