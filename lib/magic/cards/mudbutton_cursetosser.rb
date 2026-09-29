module Magic
  module Cards
    MudbuttonCursetosser = Creature("Mudbutton Cursetosser") do
      cost black: 1
      creature_type("Goblin Warlock")
      power 2
      toughness 1

      def can_block?(_permanent) = false
    end

    class MudbuttonCursetosser < Creature
      # As an additional cost to cast this spell, behold a Goblin or pay {2}.
      def additional_costs
        [Costs::Behold.new(self, type: "Goblin", or_mana: { generic: 2 })]
      end

      # When this creature dies, destroy target creature an opponent controls with power 2 or less.
      class DiesTrigger < TriggeredAbility::Death
        class TargetChoice < Magic::Choice::Targeted
          def choices = battlefield.not_controlled_by(controller).creatures.select { _1.power <= 2 }

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:destroy_target, target: target)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
