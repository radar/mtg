module Magic
  module Tokens
    class Griffin < CreatureToken
      POWER = 2
      TOUGHNESS = 2
      NAME = "Griffin"
      TYPE_LINE = "Griffin"
      KEYWORDS = [Keywords::FLYING]

      def colors
        [:white]
      end
    end
  end
end
