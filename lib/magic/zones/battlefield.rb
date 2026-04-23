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

      def permanents
        items
      end

      def cleanup
        creatures.each(&:cleanup!)
      end
    end
  end
end
