module Magic
  module Cards
    AttackInTheBox = Creature("Attack-in-the-Box") do
      cost generic: 3
      artifact_creature_type "Toy"
      power 2
      toughness 4
    end

    class AttackInTheBox < Creature
      # A game-level listener that sacrifices the permanent at the next end step, then removes itself.
      class SacrificeAtEndStep
        def initialize(game:, permanent:)
          @game = game
          @permanent = permanent
        end

        def receive_event(event)
          return unless event.is_a?(Events::BeginningOfEndStep)

          @game.unsubscribe(self)
          @permanent.sacrifice! if @permanent.zone
        end
      end

      # "Whenever this creature attacks, you may have it get +4/+0 until end of turn. If you do, sacrifice it at the
      # beginning of the next end step."
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        class MayChoice < Magic::Choice::May
          def resolve!
            pump(actor, 4, 0)
            game.subscribe(SacrificeAtEndStep.new(game: game, permanent: actor))
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => AttacksTrigger }
    end
  end
end
