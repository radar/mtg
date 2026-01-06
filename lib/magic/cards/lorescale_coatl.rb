module Magic
  module Cards
    class LorescaleCoatl < Creature
      card_name "Lorescale Coatl"
      cost "{1}{G}{U}"
      creature_type "Snake"
      power 2
      toughness 2

      class CardDrawTrigger < TriggeredAbility
        def should_perform?
          you?
        end

        def call
          actor.trigger_effect(:add_counter, source: actor, counter_type: Counters::Plus1Plus1, target: actor)
        end
      end

      def event_handlers
        {
          Events::CardDraw => CardDrawTrigger
        }
      end
    end
  end
end
