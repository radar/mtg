module Magic
  module Zones
    class Battlefield < Zone
      extend Forwardable

      def_delegators :items, :creatures, :planeswalkers, :not_controlled_by, :controlled_by, :phased_out, :nonland, :nontoken

      def battlefield?
        true
      end

      def add(permanent, _index = 0)
        raise "Attempting to add a card to battlefield -- should be a permanent" if permanent.is_a?(Magic::Card)
        @items << permanent
      end

      def static_abilities
        StaticAbilities.new(permanents.flat_map(&:static_abilities))
      end

      def receive_event(event)
        # the dup here is so that if an event adds a permanent to the array, we do not infinitely loop
        # For example:
        # 1. Scute Swarm's Triggered Landfall Abililty
        # 2. Creates a scute, adding to this array
        # 3. `.each` continues on its merry way, going to Scute #2
        # 4. Go to Step 2.
        permanents.dup.each { _1.receive_event(event) }
      end

      def permanents
        items
      end

      def cleanup
        creatures.each(&:cleanup!)
      end
    end
  end
end
