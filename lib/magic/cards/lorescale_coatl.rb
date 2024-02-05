module Magic
  module Cards
    class LorescaleCoatl < Creature
      card_name "Lorescale Coatl"
      cost "{1}{G}{U}"
      creature_type "Snake"
      power 2
      toughness 2

      def event_handlers
        {
          Events::CardDraw => ->(receiver, event) {
            return unless receiver.controller == event.player

            trigger_effect(:add_counter, source: receiver, counter_type: Counters::Plus1Plus1, target: receiver)
          }
        }
      end
    end
  end
end
