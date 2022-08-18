module Magic
  module Tokens
    class Angel < CreatureToken
      POWER = 4
      TOUGHNESS = 4
      NAME = "Angel"
      KEYWORDS = [Keywords::FLYING]
      TYPE_LINE = "Token Creature -- Angel"

      def colors
        [:white]
      end

    end
  end
end
