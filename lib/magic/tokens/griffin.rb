module Magic
  module Tokens
    class Griffin < Creature
      POWER = 2
      TOUGHNESS = 2
      NAME = "Griffin"
      TYPE_LINE = "Token Creature -- Griffin"
      KEYWORDS = [Keywords::FLYING]

      def colors
        [:white]
      end
    end
  end
end
