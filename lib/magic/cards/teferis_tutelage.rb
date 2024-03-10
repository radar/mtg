module Magic
  module Cards
    class TeferisTutelage < Enchantment
      card_name "Teferi's Tutelage"
      cost "{2}{U}"

      enters_the_battlefield do
        actor.trigger_effect(:draw_cards, player: controller)
        actor.add_choice(:discard)
      end

      class Mill < Choice
        def choices
          game.opponents(controller)
        end

        def resolve!(target:)
          target.mill(2)
        end
      end

      class DrawCardTrigger < TriggeredAbility
        def should_perform?
          event.player == controller
        end

        def call
          game.add_choice(Mill.new(actor: actor))
        end
      end


      def event_handlers
        {
          Events::CardDraw => DrawCardTrigger
        }
      end
    end
  end
end
