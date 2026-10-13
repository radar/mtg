module Magic
  module Cards
    SporogenicInfection = Aura("Sporogenic Infection") do
      cost generic: 1, black: 1
    end

    class SporogenicInfection < Aura
      enchant "Creature"

      def target_choices
        battlefield.creatures
      end

      # "When this Aura enters, target player sacrifices a creature of their choice other than enchanted creature."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class SacrificeChoice < Magic::Choice::Targeted
          def initialize(actor:, player:)
            @player = player
            super(actor:)
          end

          def choices
            battlefield.controlled_by(@player).by_any_type("Creature").reject { _1 == actor.attached_to }
          end

          def choice_amount = 1

          # The player picks which of their own creatures to sacrifice; nothing is targeted.
          def targets? = false

          def resolve!(target:)
            target.sacrifice!
          end
        end

        class PlayerChoice < Magic::Choice::Targeted
          def choices = game.players

          def choice_amount = 1

          def resolve!(target:)
            choice = SacrificeChoice.new(actor:, player: target)
            game.choices.add(choice) if choice.choices.any?
          end
        end

        def call
          game.add_choice(PlayerChoice.new(actor:))
        end
      end

      def etb_triggers = [EntersTrigger]

      # "When enchanted creature is dealt damage, destroy it."
      class DamagedTrigger < TriggeredAbility
        def should_perform?
          event.target == actor.attached_to && event.damage.positive?
        end

        def call
          destroy(actor.attached_to)
        end
      end

      def event_handlers = { Events::DamageDealt => DamagedTrigger }
    end
  end
end
