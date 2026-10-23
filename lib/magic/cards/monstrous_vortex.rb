module Magic
  module Cards
    class MonstrousVortex < Enchantment
      card_name "Monstrous Vortex"
      cost generic: 3, green: 1

      # "Whenever you cast a creature spell with power 5 or greater, discover X, where X is that spell's mana value."
      class CastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          event.player == controller && spell.creature? && spell.base_power.to_i >= 5
        end

        def call = Choice::Discover.perform(actor: actor, value: spell.mana_value)
      end

      def event_handlers = { Events::SpellCast => CastTrigger }
    end
  end
end
