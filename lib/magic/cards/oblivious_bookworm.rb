module Magic
  module Cards
    ObliviousBookworm = Creature("Oblivious Bookworm") do
      cost green: 1, blue: 1
      creature_type "Human Wizard"
      power 2
      toughness 3
    end

    class ObliviousBookworm < Creature
      # "...you may draw a card. If you do, discard a card unless a permanent entered the battlefield face down under your
      # control this turn or you turned a permanent face up this turn."
      class DrawChoice < Magic::Choice::May
        def prompt = "Draw a card?"

        def resolve!
          trigger_effect(:draw_card)
          game.add_choice(Magic::Choice::Discard.new(player: controller, actor: actor)) unless face_down_activity_this_turn?
        end

        private

        def face_down_activity_this_turn?
          game.current_turn.events.any? do |event|
            case event
            when Events::EnteredTheBattlefield then event.permanent.entered_face_down? && event.permanent.controller == controller
            when Events::TurnedFaceUp then event.player == controller
            end
          end
        end
      end

      # "At the beginning of your end step, you may draw a card. ..."
      class EndStepTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller
        end

        def call
          game.add_choice(DrawChoice.new(actor: actor))
        end
      end

      def event_handlers = { Events::BeginningOfEndStep => EndStepTrigger }
    end
  end
end
