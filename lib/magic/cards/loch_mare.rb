module Magic
  module Cards
    LochMare = Creature("Loch Mare") do
      cost generic: 1, blue: 1
      creature_type("Horse Serpent")
      power 4
      toughness 5
    end

    class LochMare < Creature
      enters_with_counters "-1/-1", 3

      class ActivatedAbility1 < Magic::ActivatedAbility
        costs "{1}{U}, Remove 1 -1/-1 counters from {this}"

        def resolve!
          trigger_effect(:draw_card)
        end
      end

      class ActivatedAbility2 < Magic::ActivatedAbility
        costs "{2}{U}, Remove 2 -1/-1 counters from {this}"

        def target_choices
          battlefield.creatures
        end

        def resolve!(target:)
          trigger_effect(:tap, target: target)
          trigger_effect(:add_counter, counter_type: "stun", target: target, amount: 1)
        end
      end

      def activated_abilities = [ActivatedAbility1, ActivatedAbility2]
    end
  end
end
