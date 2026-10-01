module Magic
  module Cards
    RescueLeopard = Creature("Rescue Leopard") do
      cost generic: 2, red: 1
      creature_type("Cat")
      power 4
      toughness 2
    end

    class RescueLeopard < Creature
      class BecomesTappedTrigger < TriggeredAbility
        def should_perform?
          event.permanent == actor
        end

        class MayChoice < Magic::Choice::May
          class DiscardChoice < Magic::Choice::Discard
            def resolve!(**args)
              super(**args)
              trigger_effect(:draw_card)
            end
          end

          def resolve!
            game.choices.add(DiscardChoice.new(actor: actor, player: controller))
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def event_handlers = { Events::PermanentTapped => BecomesTappedTrigger }
    end
  end
end
