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
          pump(target, 5, 5)
          give_keyword(target, :trample)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
