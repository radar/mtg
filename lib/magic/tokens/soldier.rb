module Magic
  module Tokens
    class Soldier < CreatureToken
      POWER = 1
      TOUGHNESS = 1
      NAME = "Soldier"
      TYPE_LINE = "Soldier"

      def colors
        [:white]
      end
    end
  end
end
