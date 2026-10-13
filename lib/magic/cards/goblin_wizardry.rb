module Magic
  module Cards
    GoblinWizardry = Instant("Goblin Wizardry") do
      cost red: 1, generic: 3
    end

    class GoblinWizardry < Instant
      GoblinWizardToken = Token.create "Goblin Wizard" do
        creature_type "Goblin Wizard"
        power 1
        toughness 1
        colors :red
        keywords :prowess
      end

      def resolve!
        create_token(token:GoblinWizardToken, amount: 2)

        super
      end
    end
  end
end
