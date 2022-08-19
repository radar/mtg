module Magic
  module Tokens
    class Knight < CreatureToken
      POWER = 2
      TOUGHNESS = 2
      NAME = "Knight"
      KEYWORDS = [Keywords::VIGILANCE]
      TYPE_LINE = "Token Creature -- Knight"

      def colors
        [:white]
      end

    end
  end
end
