module Magic
  module Tokens
    class ElfWarrior < Creature
      POWER = 1
      TOUGHNESS = 1
      NAME = "Elf Warrior"
      TYPE_LINE = "Token Creature -- Elf Warrior"

      def colors
        [:green]
      end
    end
  end
end
