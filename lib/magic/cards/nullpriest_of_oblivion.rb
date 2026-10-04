module Magic
  module Cards
    NullpriestOfOblivion = Creature("Nullpriest of Oblivion") do
      cost generic: 1, black: 1
      creature_type("Vampire Cleric")
      keywords :lifelink, :menace
      kicker_cost generic: 3, black: 1
      power 2
      toughness 1
    end

    class NullpriestOfOblivion < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          actor.kicked?
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            controller.graveyard.cards.select { _1.type?("Creature") }
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

      def etb_triggers = [EntersTrigger]
    end
  end
end
