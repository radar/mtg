module Magic
  module Events
    class Landfall
      attr_reader :land

      def initialize(land)
        @land = land
      end

      def inspect
        "#<Events::Landfall permanent: #{land.name}>"
      end

      def player
        land.controller
      end
    end
  end
end
