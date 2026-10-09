module Magic
  module Cards
    GreatFierceBee = Creature("Great Fierce Bee") do
      cost generic: 2, black: 1
      creature_type "Insect"
      power 2
      toughness 2
      keywords :flying
    end

    class GreatFierceBee < Creature
      # "Whenever one or more other creatures die, scry 1."
      class CreaturesDiedTrigger < TriggeredAbility
        def should_perform?
          return false if event.permanent == actor

          # Creatures dying together are one trigger: skip if one is already waiting.
          game.pending_triggers.none? { |ability| ability.is_a?(CreaturesDiedTrigger) && ability.actor == actor }
        end

        def call
          game.add_choice(Choice::Scry.new(actor: actor, amount: 1))
        end
      end

      def event_handlers
        super.merge({ Events::CreatureDied => CreaturesDiedTrigger }) { |_, a, b| Array(a) + Array(b) }
      end
    end
  end
end
