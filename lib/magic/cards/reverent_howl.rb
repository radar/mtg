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
          trigger_effect(:lose_life, target: target, life: 2)
        end
      end

      # Target creature gets +2/+2 and gains lifelink until end of turn.
      class Pump < Mode
        def target_choices = battlefield.creatures

        def resolve!(target:)
          trigger_effect(:modify_power_toughness, target: target, power: 2, toughness: 2)
          trigger_effect(:grant_keyword, target: target, keyword: :lifelink)
        end
      end

      modes DrawAndLose, Pump
      choose_modes 1
    end
  end
end
