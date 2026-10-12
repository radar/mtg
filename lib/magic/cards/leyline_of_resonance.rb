module Magic
  module Cards
    LeylineOfResonance = Enchantment("Leyline of Resonance") do
      cost generic: 2, red: 2
      begins_on_battlefield
    end

    class LeylineOfResonance < Enchantment
      # "Whenever you cast an instant or sorcery spell that targets only a single creature you control, copy that spell. You
      # may choose new targets for the copy."
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && (spell.instant? || spell.sorcery?) && single_creature_you_control?
        end

        def call
          Magic::CopyEffect.resolve_with_choice!(actor: actor, receiver: spell, targets: event.targets)
        end

        private

        def single_creature_you_control?
          targets = event.targets
          targets.one? && targets.first.is_a?(Permanent) && targets.first.creature? && targets.first.controller == controller
        end
      end

      def event_handlers = { Events::SpellCast => SpellCastTrigger }
    end
  end
end
