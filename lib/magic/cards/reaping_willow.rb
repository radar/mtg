module Magic
  module Cards
    ReapingWillow = Creature("Reaping Willow") do
      cost generic: 1, white_or_black: 3
      creature_type("Treefolk Cleric")
      keywords :lifelink
      power 3
      toughness 6
    end

    class ReapingWillow < Creature
      enters_with_counters "-1/-1", 2

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}{W/B}, Remove 2 -1/-1 counters from {this}"

        def requirements_met? = game.can_cast_sorcery?(controller)

        def target_choices
          controller.graveyard.cards.select { |card| card.type?("Creature") && card.mana_value <= 3 }
        end

        def resolve!(target:)
          trigger_effect(:return_target_from_graveyard_to_battlefield, target: target)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
