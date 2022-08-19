module Magic
  module Zones
    class Battlefield < Zone
      def initialize(**args)
        super(**args)
      end

      def battlefield?
        true
      end

      def add(permanent)
        raise "#{permanent} is not a permanent, so cannot be added to the battlefield." unless permanent.is_a?(Permanent)
        super(permanent)
      end

      def static_abilities
        StaticAbilities.new(@cards.flat_map(&:static_abilities))
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

      def cleanup
        creatures.each(&:cleanup!)
      end
    end
  end
end
