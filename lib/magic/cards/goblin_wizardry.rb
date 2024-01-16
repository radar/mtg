module Magic
  module Cards
    GoblinWizardry = Instant("Goblin Wizardry") do
      cost red: 1, generic: 3
    end

    class GoblinWizardry < Instant

      def resolve!
        controller.create_token(token: Tokens::GoblinWizard, amount: 2)

        super
      end
    end
  end
end
