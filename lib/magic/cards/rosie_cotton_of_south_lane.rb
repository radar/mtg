module Magic
  module Cards
    RosieCottonOfSouthLane = Creature("Rosie Cotton of South Lane") do
      cost generic: 2, white: 1
      legendary_creature_type "Halfling Peasant"
      power 1
      toughness 1
    end

    class RosieCottonOfSouthLane < Creature
      # "When Rosie Cotton enters, create a Food token."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          create_token(token: Tokens::Food)
        end
      end

      # "Whenever you create a token, put a +1/+1 counter on target creature you control other than Rosie Cotton."
      class TokenTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices = controller.creatures.reject { _1 == actor }

          def choice_amount = 1

          def resolve!(target:)
            add_counter("+1/+1", to: target)
          end
        end

        def should_perform?
          event.permanent.token? && under_your_control?
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers = { Events::EnteredTheBattlefield => TokenTrigger }
    end
  end
end
