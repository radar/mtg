module Magic
  module Cards
    BurdenedStoneback = Creature("Burdened Stoneback") do
      cost generic: 1, white: 1
      creature_type("Giant Warrior")
      power 4
      toughness 4
    end

    class BurdenedStoneback < Creature
      enters_with_counters "-1/-1", 2

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}{W}, Remove 1 -1/-1 counters from {this}"

        def requirements_met? = game.can_cast_sorcery?(controller)

        def target_choices
          battlefield.creatures
        end

        def resolve!(target:)
          trigger_effect(:grant_keyword, target: target, keyword: :indestructible)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
