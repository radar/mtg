module Magic
  module Cards
    BramblebackBrute = Creature("Brambleback Brute") do
      cost generic: 2, red: 1
      creature_type("Giant Warrior")
      power 4
      toughness 5
    end

    class BramblebackBrute < Creature
      enters_with_counters "-1/-1", 2

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}{R}, Remove 1 -1/-1 counters from {this}"

        activate_only_as_sorcery

        def target_choices
          battlefield.creatures
        end

        def resolve!(target:)
          target.prevent_blocking!
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
