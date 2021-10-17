module Magic
  module Tokens
    class Bird < CreatureToken
      POWER = 1
      TOUGHNESS = 1
      NAME = "Bird"
      KEYWORDS = [Keywords::FLYING]
      TYPE_LINE = "Bird"

      def colors
        [:white]
      end
    end
  end
end
