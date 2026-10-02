module Magic
  module Cards
    FelidarCub = Creature("Felidar Cub") do
      cost generic: 1, white: 1
      creature_type("Cat Beast")
      power 2
      toughness 2
    end

    class FelidarCub < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "Sacrifice {this}"

        def target_choices
          battlefield.enchantments
        end

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
