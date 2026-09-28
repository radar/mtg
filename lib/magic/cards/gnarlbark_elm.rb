module Magic
  module Cards
    GnarlbarkElm = Creature("Gnarlbark Elm") do
      cost generic: 2, black: 1
      creature_type("Treefolk Warlock")
      power 3
      toughness 4
    end

    class GnarlbarkElm < Creature
      enters_with_counters "-1/-1", 2

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{2}{B}, Remove 2 -1/-1 counters from {this}"

        activate_only_as_sorcery

        def target_choices
          battlefield.creatures
        end

        def resolve!(target:)
          trigger_effect(:modify_power_toughness, target: target, power: -2, toughness: -2)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
