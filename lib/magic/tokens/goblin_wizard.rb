module Magic
  module Tokens
    GoblinWizard = Creature("Goblin Wizard") do
      creature_type "Goblin Wizard"
      power 1
      toughness 1
      keywords :prowess

      def colors
        [:red]
      end
    end
  end
end
