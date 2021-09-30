module Magic
  module Zones
    class Battlefield < Zone
      attr_reader :static_abilities

      def initialize(**args)
        @static_abilities = []
        super(**args)
      end

      def battlefield?
        true
      end

      def add_static_ability(ability)
        @static_abilities << ability
      end

      def remove_static_ability(ability)
        @static_abilities -= [ability]
      end

      def receive_event(event)
        case event
        when Events::ZoneChange
          if event.to == :battlefield
            cards << event.card
          end

          if event.from == :battlefield
            self.cards -= [event.card]
          end
        end

        @cards.each { |card| card.receive_notification(event) }
      end

      def untap(&block)
        block.call(cards).each(&:untap!)
      end

      def creatures
        @cards.creatures
      end

      def creatures_controlled_by(player)
        @cards.creatures.controlled_by(player)
      end
    end
  end
end
