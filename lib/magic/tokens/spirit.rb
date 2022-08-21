module Magic
  module Tokens
    class Spirit < Creature
      POWER = 1
      TOUGHNESS = 1
      NAME = "Spirit"
      KEYWORDS = [Keywords::FLYING]
      TYPE_LINE = "Token Creature -- Spirit"

      def colors
        [:white]
      end

    end
  end
end
