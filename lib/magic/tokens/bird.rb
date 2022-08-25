module Magic
  module Tokens
    class Bird < Creature
      POWER = 1
      TOUGHNESS = 1
      NAME = "Bird"
      KEYWORDS = [Keywords::FLYING]
      TYPE_LINE = "Token Creature -- Bird"

      def colors
        [:white]
      end
    end
  end
end
