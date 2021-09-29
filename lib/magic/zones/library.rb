module Magic
  module Zones
    class Library < Zone
      def draw
        @cards.shift
      end
    end
  end
end
