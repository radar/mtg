module Magic
  module Cards
    PerforatingArtist = Creature("Perforating Artist") do
      cost generic: 1, black: 1, red: 1
      creature_type("Devil")
      keywords :deathtouch
      power 3
      toughness 2
    end

    class PerforatingArtist < Creature
      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step? && (game.current_turn.events.any? { |e| e.is_a?(Events::CreatureAttacked) && e.attacker.controller == controller })
        end

        def call
          game.opponents(controller).each { |player| game.add_choice(Magic::Choice::LoseLifeUnless.new(actor: actor, player: player, life: 3, discard: true, sacrifice: true)) }
        end
      end

      def event_handlers = { Events::BeginningOfEndStep => EndStepTrigger }
    end
  end
end
