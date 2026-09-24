module Magic
  module Cards
    SilvergillPeddler = Creature("Silvergill Peddler") do
      cost generic: 2, blue: 1
      creature_type("Merfolk Citizen")
      power 2
      toughness 3
    end

    class SilvergillPeddler < Creature
      class BecomesTappedTrigger < TriggeredAbility
        def should_perform?
          event.permanent == actor
        end

        def call
          trigger_effect(:draw_cards, number_to_draw: 1)
          game.add_choice(Magic::Choice::Discard.new(player: controller))
        end
      end

      def event_handlers = { Events::PermanentTapped => BecomesTappedTrigger }
    end
  end
end
