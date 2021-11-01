module Magic
  module Zones
    class Battlefield < Zone
      attr_reader :static_abilities

      def initialize(**args)
        @static_abilities = StaticAbilities.new([])
        super(**args)
      end

      def battlefield?
        true
      end

      def receive_event(event)
        case event
        when Events::EnteredZone
          if event.to == :battlefield
            add(event.card)
          end

        when Events::LeavingZone
          if event.from == :battlefield
            remove(event.card)
          end
        end

        @cards.each { |card| card.receive_notification(event) }
      end

      def untap(&block)
        block.call(cards).each(&:untap!)
      end
    end
  end
end
