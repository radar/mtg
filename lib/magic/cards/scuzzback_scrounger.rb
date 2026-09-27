module Magic
  module Cards
    ScuzzbackScrounger = Creature("Scuzzback Scrounger") do
      cost generic: 1, red: 1
      creature_type("Goblin Warrior")
      power 3
      toughness 2
    end

    class ScuzzbackScrounger < Creature
      class MainPhaseTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller
        end

        class MayChoice < Magic::Choice::May
          class BlightChoice < Magic::Choice::Blight
            def resolve!(**args)
              super(**args)
              trigger_effect(:create_token, token_class: Tokens::Treasure)
            end
          end

          def resolve!
            game.choices.add(BlightChoice.new(actor: actor, amount: 1)) if Magic::Choice::Blight.possible?(controller, game)
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def event_handlers = { Events::FirstMainPhase => MainPhaseTrigger }
    end
  end
end
