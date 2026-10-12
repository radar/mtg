module Magic
  module Cards
    AlaniaDivergentStorm = Creature("Alania, Divergent Storm") do
      legendary_creature_type "Otter Wizard"
      cost generic: 3, blue: 1, red: 1
      power 3
      toughness 5
    end

    class AlaniaDivergentStorm < Creature
      # Whenever you cast a spell, if it's the first instant spell, the first sorcery spell, or the first Otter
      # spell other than Alania you've cast this turn, you may have target opponent draw a card. If you do, copy
      # that spell. You may choose new targets for the copy.
      class CastTrigger < TriggeredAbility::SpellCast
        class MayCopy < Magic::Choice::May
          def initialize(actor:, event:)
            @event = event
            super(actor: actor)
          end

          def resolve!
            game.opponents(controller).first&.draw!
            Magic::CopyEffect.resolve_with_choice!(actor: actor, receiver: @event.spell, targets: @event.targets)
          end
        end

        def should_perform?
          return false unless event.player == controller

          earlier = game.current_turn.spells_cast.select { _1.player == controller }.reject { _1.equal?(event) }.map(&:spell)
          (spell.instant? && earlier.none?(&:instant?)) ||
            (spell.sorcery? && earlier.none?(&:sorcery?)) ||
            (spell.type?("Otter") && spell != actor.card && earlier.none? { _1.type?("Otter") && _1 != actor.card })
        end

        def call
          game.choices.add(MayCopy.new(actor: actor, event: event))
        end
      end

      def event_handlers = super.merge(Events::SpellCast => CastTrigger)
    end
  end
end
