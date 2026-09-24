module Magic
  module Cards
    PitilessFists = Aura("Pitiless Fists") do
      cost generic: 3, green: 1
    end

    class PitilessFists < Aura
      enchant "Creature", you_control: true

      def target_choices
        battlefield.controlled_by(controller).creatures
      end

      class EnchantedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 2
        applies_to_target
      end

      def static_abilities = [EnchantedCreatureBuff]

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.not_controlled_by(controller).creatures
          end

          def choice_amount = 0..1

          def resolve!(target:)
            actor.attached_to.fights!(target)
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
