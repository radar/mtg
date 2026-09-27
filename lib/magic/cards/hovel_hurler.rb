module Magic
  module Cards
    HovelHurler = Creature("Hovel Hurler") do
      cost generic: 3, red_or_white: 2
      creature_type("Giant Warrior")
      power 6
      toughness 7
    end

    class HovelHurler < Creature
      enters_with_counters "-1/-1", 2

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{R/W}{R/W}, Remove 1 -1/-1 counters from {this}"

        def requirements_met? = game.can_cast_sorcery?(controller)

        def target_choices
          (battlefield.controlled_by(controller).creatures - [source])
        end

        def resolve!(target:)
          trigger_effect(:modify_power_toughness, target: target, power: 1, toughness: 0)
          trigger_effect(:grant_keyword, target: target, keyword: :flying)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
