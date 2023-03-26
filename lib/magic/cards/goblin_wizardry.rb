module Magic
  module Cards
    GoblinWizardry = Instant("Goblin Wizardry") do
      cost red: 1, generic: 3
    end

    class GoblinWizardry < Instant

      def resolve!(controller)
        2.times do
          Permanent.resolve(
            game: game,
            owner: controller,
            card: Tokens::GoblinWizard.new
          )
        end
        super
      end
    end
  end
end
