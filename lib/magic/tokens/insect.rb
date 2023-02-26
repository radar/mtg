module Magic
  module Tokens
    class Insect < Creature
      POWER = 1
      TOUGHNESS = 1
      NAME = "Insect"
      TYPE_LINE = "Token Creature -- Insect"

      def colors
        [:green]
      end

    end
  end
end
