module Magic
  module Cards
    HumbleDefector = Creature("Humble Defector") do
      cost generic: 1, red: 1
      creature_type "Human Rogue"
      power 2
      toughness 1
    end

    class HumbleDefector < Creature
      class DrawAndGiveControl < Magic::ActivatedAbility
        costs "{T}"

        def requirements_met?
          game.current_turn.active_player == controller
        end

        def single_target?
          true
        end

        def target_choices
          game.opponents(controller)
        end

        def resolve!(target:)
          trigger_effect(:draw_cards, number_to_draw: 2)
          source.controller = target
        end
      end

      def activated_abilities = [DrawAndGiveControl]
    end
  end
end
