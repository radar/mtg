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

      # The top card, still in the library: the caller moves it (`Card#move_to_graveyard!`), so replacement
      # effects see it in its zone ("If ~ would be put into a graveyard from anywhere", Darksteel Colossus).
      def mill
        @items.first
      end

    end
  end
end
