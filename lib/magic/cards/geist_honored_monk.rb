module Magic
  module Cards
    class GeistHonoredMonk < Creature
      NAME = "Geist Honored Monk"
      TYPE_LINE = "Creature -- Human Monk"

      def power
        controlled_creatures_count
      end

      def toughness
        controlled_creatures_count
      end

      private

      def controlled_creatures_count
        controller.creatures.count
      end
    end
  end
end
