module Magic
  module Cards
    GutsplitterGang = Creature("Gutsplitter Gang") do
      cost generic: 3, black: 1
      creature_type("Goblin Berserker")
      power 6
      toughness 6
    end

    class GutsplitterGang < Creature
      class MainPhaseTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller
        end

        class MayChoice < Magic::Choice::May
          def resolve!
            game.choices.add(Magic::Choice::Blight.new(actor: actor, amount: 2)) if Magic::Choice::Blight.possible?(controller, game)
          end

          def decline!
            trigger_effect(:lose_life, target: controller, life: 3)
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
