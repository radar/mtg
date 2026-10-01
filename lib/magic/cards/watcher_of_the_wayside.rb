module Magic
  module Cards
    WatcherOfTheWayside = Creature("Watcher of the Wayside") do
      cost generic: 3
      artifact_creature_type("Golem")
      power 3
      toughness 2
    end

    class WatcherOfTheWayside < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            game.players
          end

          def choice_amount = 1

          def resolve!(target:)
            target.mill(2)
            trigger_effect(:gain_life, target: controller, life: 2)
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
