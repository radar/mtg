module Magic
  module Cards
    GoblinWizardry = Instant("Goblin Wizardry") do
      cost red: 1, generic: 3
    end

    class GoblinWizardry < Instant
      
      def resolve!(controller)
        Permanent.resolve(game: game, owner: controller, card: Tokens::GoblinWizard.new)
        Permanent.resolve(game: game, owner: controller, card: Tokens::GoblinWizard.new)
        super
      end
    end
  end
end
