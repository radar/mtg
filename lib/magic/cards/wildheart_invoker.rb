module Magic
  module Cards
    WildheartInvoker = Creature("Wildheart Invoker") do
      cost generic: 2, green: 2
      creature_type("Elf Shaman")
      power 4
      toughness 3
    end

    class WildheartInvoker < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{8}"

        def target_choices
          battlefield.creatures
        end

        def resolve!(target:)
          trigger_effect(:modify_power_toughness, target: target, power: 5, toughness: 5)
          trigger_effect(:grant_keyword, target: target, keyword: :trample)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
