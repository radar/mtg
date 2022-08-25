module Magic
  module Tokens
    class Soldier < Creature
      POWER = 1
      TOUGHNESS = 1
      NAME = "Soldier"
      TYPE_LINE = "Token Creature -- Soldier"

      def colors
        [:white]
      end
    end
  end
end
