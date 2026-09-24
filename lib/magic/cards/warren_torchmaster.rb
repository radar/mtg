module Magic
  module Cards
    WarrenTorchmaster = Creature("Warren Torchmaster") do
      cost generic: 1, red: 1
      creature_type("Goblin Warrior")
      power 2
      toughness 2
    end

    class WarrenTorchmaster < Creature
      class BeginningOfCombatTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller
        end

        class MayChoice < Magic::Choice::May
          class BlightChoice < Magic::Choice::Blight
            class TargetChoice < Magic::Choice::Targeted
              def choices
                battlefield.creatures
              end

              def choice_amount = 1

              def resolve!(target:)
                trigger_effect(:grant_keyword, target: target, keyword: :haste)
              end
            end

            def resolve!(**args)
              super(**args)
              choice = TargetChoice.new(actor: actor)
              game.add_choice(choice) if choice.choices.any?
            end
          end

          def resolve!
            game.choices.add(BlightChoice.new(actor: actor, amount: 1)) if Magic::Choice::Blight.possible?(controller, game)
          end
        end

        def call
          return if battlefield.creatures.none?
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def event_handlers = { Events::BeginningOfCombat => BeginningOfCombatTrigger }
    end
  end
end
