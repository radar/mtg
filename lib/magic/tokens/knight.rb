module Magic
  module Tokens
    class Knight < CreatureToken
      POWER = 2
      TOUGHNESS = 2
      NAME = "Knight"
      KEYWORDS = [Cards::Keywords::VIGILANCE]
      TYPE_LINE = "Knight"

      def colors
        [:white]
      end

    end
  end
end
