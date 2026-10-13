module Magic
  module Cards
    class SeasonOfTheBurrow < Sorcery
      card_name "Season of the Burrow"
      cost generic: 3, white: 2

      # {P} -- Create a 1/1 white Rabbit creature token.
      class MakeRabbit < Mode
        points 1

        def resolve!
          create_token(token:Tokens::Rabbit)
        end
      end

      # {P}{P} -- Exile target nonland permanent. Its controller draws a card.
      class ExileAndDraw < Mode
        points 2

        def target_choices = battlefield.reject(&:land?)

        def resolve!(target:)
          player = target.controller
          exile_target(target)
          trigger_effect(:draw_cards, player: player, number_to_draw: 1)
        end
      end

      # {P}{P}{P} -- Return target permanent card with mana value 3 or less from your graveyard to the battlefield
      # with an indestructible counter on it.
      class ReturnWithCounter < Mode
        points 3

        def target_choices = controller.graveyard.permanents.select { _1.mana_value <= 3 }

        def resolve!(target:)
          trigger_effect(:return_target_from_graveyard_to_battlefield, target: target, controller: controller, counters: { "indestructible" => 1 })
        end
      end

      modes MakeRabbit, ExileAndDraw, ReturnWithCounter
      modes_budget 5
    end
  end
end
