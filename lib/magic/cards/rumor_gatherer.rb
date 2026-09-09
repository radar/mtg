module Magic
  module Cards
    RumorGatherer = Creature("Rumor Gatherer") do
      cost generic: 1, white: 2
      creature_type "Elf Wizard"
      power 2
      toughness 1
    end

    class RumorGatherer < Creature
      class AllianceTrigger < TriggeredAbility
        def should_perform?
          event.is_a?(Events::EnteredTheBattlefield) &&
            event.permanent != actor &&
            event.permanent.creature? &&
            event.permanent.controller == controller
        end

        def call
          entries = game.current_turn.events.count do |event|
            event.is_a?(Events::EnteredTheBattlefield) &&
              event.permanent != actor &&
              event.permanent.creature? &&
              event.permanent.controller == controller
          end

          if entries == 2
            controller.draw!
          else
            game.add_choice(Choice::Scry.new(actor: actor))
          end
        end
      end

      def event_handlers
        { Events::EnteredTheBattlefield => AllianceTrigger }
      end
    end
  end
end