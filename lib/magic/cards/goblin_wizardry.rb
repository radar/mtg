module Magic
  module Cards
    GoblinWizardry = Instant("Goblin Wizardry") do
      cost white: 1, generic: 4
    end

    class Goblin Wizardry < Instant
      def target_choices
        battlefield.creatures
      end

      def single_target?
        true
      end

      def resolve!(controller, target:)
        target.exile!

        Permanent.resolve(game: game, owner: target.controller, card: Tokens::Soldier.new)

        super
      end
    end
  end
end
