module Magic
  module Cards
    ConduitGoblin = Creature("Conduit Goblin") do
      cost red: 1, white: 1
      creature_type("Goblin Warrior")
      power 2
      toughness 2
    end

    class ConduitGoblin < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          gain_energy 2
        end
      end

      # "At the beginning of combat on your turn, you may pay {E}. If you do, another target creature you control gets
      # +1/+0 and gains haste until end of turn."
      class BeginningOfCombatTrigger < TriggeredAbility
        class TargetChoice < Magic::Choice::Targeted
          def choices = controller.creatures.reject { _1 == actor }

          def choice_amount = 1

          def resolve!(target:)
            pump(target, 1, 0)
            give_keyword(target, :haste)
          end
        end

        class PayChoice < Magic::Choice::PayEnergy
          def resolve!
            super
            choice = TargetChoice.new(actor: actor)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        def should_perform?
          event.active_player == controller
        end

        def call
          choice = PayChoice.new(actor: actor)
          game.add_choice(choice) if choice.can_pay?
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers = { Events::BeginningOfCombat => BeginningOfCombatTrigger }
    end
  end
end
