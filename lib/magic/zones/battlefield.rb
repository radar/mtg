module Magic
  module Zones
    class Battlefield < Zone
      extend Forwardable

      def_delegators :permanents, :creatures, :planeswalkers, :not_controlled_by, :controlled_by, :phased_out, :nonland, :nontoken

      def initialize(**args)
        super(**args)
      end

      def battlefield?
        true
      end

      def add(permanent)
        raise "Attempting to add a card to battlefield -- should be a permanent" if permanent.is_a?(Magic::Card)
        super(permanent)
      end

      def static_abilities
        StaticAbilities.new(@cards.flat_map(&:static_abilities))
      end

      def permanents
        cards.permanents
      end

      def receive_event(event)
        permanents.each { _1.receive_notification(event) }
      end

      def cleanup
        creatures.each(&:cleanup!)
      end
    end
  end
end
