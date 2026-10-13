module Magic
  module Cards
    class SabertoothMauler < Creature
      card_name "Sabertooth Mauler"
      creature_type "Cat"
      cost generic: 3, green: 1
      power 3
      toughness 3

      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          return false unless controllers_end_step?
          game.current_turn.events.any? { |e| e.is_a?(Events::CreatureDied) }
        end

        def call
          add_counter "+1/+1"
          actor.untap!
        end
      end

      def event_handlers
        {
          Events::BeginningOfEndStep => EndStepTrigger
        }
      end
    end
  end
end
