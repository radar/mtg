module Magic
  module Cards
    SunBlessedHealer = Creature("Sun-Blessed Healer") do
      cost generic: 1, white: 1
      creature_type("Human Cleric")
      keywords :lifelink
      kicker_cost generic: 1, white: 1
      power 3
      toughness 1
    end

    class SunBlessedHealer < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          actor.kicked?
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            controller.graveyard.cards.select { _1.permanent? && !_1.land? && _1.mana_value <= 2 }
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
