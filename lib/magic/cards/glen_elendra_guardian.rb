module Magic
  module Cards
    GlenElendraGuardian = Creature("Glen Elendra Guardian") do
      cost generic: 2, blue: 1
      creature_type("Faerie Wizard")
      keywords :flash, :flying
      power 3
      toughness 4
    end

    class GlenElendraGuardian < Creature
      enters_with_counters "-1/-1", 1

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}{U}, Remove 1 -1/-1 counters from {this}"

        def target_choices
          game.stack.spells.select { |spell| !spell.card.type?("Creature") }
        end

        def resolve!(target:)
          spell_controller = target.player
          trigger_effect(:counter_spell, target: target)
          trigger_effect(:draw_cards, player: spell_controller, number_to_draw: 1)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
