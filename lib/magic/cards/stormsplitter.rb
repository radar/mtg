module Magic
  module Cards
    Stormsplitter = Creature("Stormsplitter") do
      cost generic: 3, red: 1
      creature_type("Otter Wizard")
      keywords :haste
      power 1
      toughness 4
    end

    class Stormsplitter < Creature
      # Whenever you cast an instant or sorcery spell, create a token that's a copy of this creature. Exile that
      # token at the beginning of the next end step.
      class CastTrigger < TriggeredAbility::SpellCast
        def should_perform? = event.player == controller && (spell.instant? || spell.sorcery?)

        def call
          copy = Permanent.resolve(game: game, owner: controller, card: actor.copiable_card, token: true, copy: true, cast: false)
          return unless copy

          copy.register_turn_trigger(Events::BeginningOfEndStep, ExileAtEnd)
        end
      end

      class ExileAtEnd < TriggeredAbility
        def call
          actor.exile!
        end
      end

      def event_handlers = super.merge(Events::SpellCast => CastTrigger)
    end
  end
end
