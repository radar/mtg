module Magic
  module Cards
    class GeistHonoredMonk < Creature
      NAME = "Geist Honored Monk"
      TYPE_LINE = "Creature -- Human Monk"

      def power
        other_controlled_creatures_count
      end

      def toughness
        other_controlled_creatures_count
      end

      private

      def other_controlled_creatures_count
        controller.game.battlefield.creatures_controlled_by(controller).count
      end
    end
  end
end
