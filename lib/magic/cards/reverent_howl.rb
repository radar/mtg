module Magic
  module Cards
    class ReverentHowl < Instant
      card_name "Reverent Howl"
      cost generic: 2, black: 1

      # Target player draws two cards and loses 2 life.
      class DrawAndLose < Mode
        def target_choices = game.players

        def resolve!(target:)
          trigger_effect(:draw_cards, player: target, number_to_draw: 2)
          lose_life(target, 2)
        end
      end

      # Target creature gets +2/+2 and gains lifelink until end of turn.
      class Pump < Mode
        def target_choices = battlefield.creatures

        def resolve!(target:)
          pump(target, 2, 2)
          give_keyword(target, :lifelink)
        end
      end

      modes DrawAndLose, Pump
      choose_modes 1
    end
  end
end
