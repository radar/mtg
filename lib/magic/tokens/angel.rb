module Magic
  module Tokens
    class Angel < CreatureToken
      POWER = 4
      TOUGHNESS = 4
      NAME = "Angel"
      KEYWORDS = [Cards::Keywords::FLYING]
      TYPE_LINE = "Angel"

      def colors
        [:white]
      end

    end
  end
end
