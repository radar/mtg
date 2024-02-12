module Magic
  module Zones
    class Library < Zone
      def library?
        true
      end

      def draw
        @items.shift
      end

      def shuffle!
        @items.shuffle!
      end

      def mill
        @items.shift
      end

    end
  end
end
