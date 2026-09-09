module Magic
  module Cards
    EnchantresssPresence = Enchantment("Enchantress's Presence") do
      cost generic: 2, green: 1
    end

    class EnchantresssPresence < Enchantment
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && enchantment?
        end

        def call
          controller.draw!
        end
      end

      def event_handlers
        { Events::SpellCast => SpellCastTrigger }
      end
    end
  end
end