module Magic
  module Cards
    BaseballBat = Equipment("Baseball Bat") do
      cost green: 1, white: 1
      equip [Costs::Mana.new(generic: 3)]
    end

    class BaseballBat < Equipment
      class EquippedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        applies_to_target
      end

      def static_abilities = [EquippedCreatureBuff]

      # "When this Equipment enters, attach it to target creature you control."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            actor.attach_to!(target)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]

      # "Whenever equipped creature attacks, tap up to one target creature."
      class AttacksTrigger < TriggeredAbility
        class TapChoice < Magic::Choice::Targeted
          def choices = battlefield.creatures

          def choice_amount = 0..1

          def resolve!(target: nil)
            target&.tap!
          end
        end

        def should_perform?
          actor.attached_to && event.attacker == actor.attached_to
        end

        def call
          game.add_choice(TapChoice.new(actor: actor))
        end
      end

      def event_handlers
        super.merge(Events::CreatureAttacked => AttacksTrigger)
      end
    end
  end
end
