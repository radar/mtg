module Magic
  module Zones
    class Library < Zone
      def library?
        true
      end

      def draw
        @cards.shift
      end
    end
  end
end
