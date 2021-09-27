module Magic
  module Cards
    class GeistHonoredMonk < Creature
      def initialize(**args)
        super(name: "Geist Honored Monk", type_line: "Creature -- Human Monk", **args)
      end

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
