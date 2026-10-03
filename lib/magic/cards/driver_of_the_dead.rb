module Magic
  module Cards
    DriverOfTheDead = Creature("Driver of the Dead") do
      cost generic: 3, black: 1
      creature_type("Vampire")
      power 3
      toughness 2
    end

    class DriverOfTheDead < Creature
      class DiesTrigger < TriggeredAbility::Death
        class TargetChoice < Magic::Choice::Targeted
          def choices
            controller.graveyard.cards.select { _1.type?("Creature") && _1.mana_value <= 2 }
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:return_target_from_graveyard_to_battlefield, target: target, controller: target.owner)
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
