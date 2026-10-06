module Magic
  module Cards
    DualcasterMage = Creature("Dualcaster Mage") do
      cost generic: 1, red: 2
      creature_type "Human Wizard"
      keywords :flash
      power 2
      toughness 2
    end

    class DualcasterMage < Creature
      # "When this creature enters, copy target instant or sorcery spell. You may choose new targets for the copy."
      class CopyChoice < Magic::Choice::Targeted
        def targets? = false

        def choices
          game.stack.spells.select { |spell| spell.card.instant? || spell.card.sorcery? }
        end

        def choice_amount = 1

        def resolve!(target:)
          Magic::CopyEffect.resolve_with_choice!(actor: actor, receiver: target.card, targets: target.targets)
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          choice = CopyChoice.new(actor: actor)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
