module Magic
  module Cards
    DoubleVision = Enchantment("Double Vision") do
      cost "{3}{R}{R}"
    end

    class DoubleVision < Enchantment
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && (spell.instant? || spell.sorcery?) && !actor.triggered_once_this_turn?(SpellCastTrigger)
        end

        def call
          actor.trigger_once_this_turn!(SpellCastTrigger)
          Magic::CopyEffect.resolve_with_choice!(actor: actor, receiver: spell, targets: event.targets)
        end
      end

      def event_handlers
        { Events::SpellCast => SpellCastTrigger }
      end
    end
  end
end
