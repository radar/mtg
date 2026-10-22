module Magic
  module Cards
    StaticPrison = Enchantment("Static Prison") do
      cost white: 1
    end

    class StaticPrison < Enchantment
      # When this enchantment enters, exile target nonland permanent an opponent controls until this enchantment leaves
      # the battlefield. You get {E}{E}.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.not_controlled_by(controller).nonland
          end

          def choice_amount = 0..1

          def resolve!(target:)
            actor.exile_until_leaves!(target)
            finish
          end

          def decline! = finish

          def finish
            gain_energy 2
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          choice.choices.any? ? game.add_choice(choice) : choice.finish
        end
      end

      # Sacrifice this enchantment unless you pay {E}. Mandatory: declining (or having no energy) sacrifices it.
      class UpkeepChoice < Magic::Choice::PayEnergy
        def decline!
          sacrifice actor
        end
      end

      # At the beginning of your first main phase, sacrifice this enchantment unless you pay {E}.
      class FirstMainPhaseTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller
        end

        def call
          choice = UpkeepChoice.new(actor: actor)
          choice.can_pay? ? game.add_choice(choice) : choice.decline!
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers = { Events::FirstMainPhase => FirstMainPhaseTrigger }
    end
  end
end
