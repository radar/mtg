module Magic
  module Cards
    KozileksUnsealing = Enchantment("Kozilek's Unsealing") do
      cost generic: 2, blue: 1
      keywords :devoid
    end

    class KozileksUnsealing < Enchantment
      # "Whenever you cast a creature spell with mana value 4, 5, or 6, create two 0/1 colorless Eldrazi Spawn..."
      class SpawnTrigger < TriggeredAbility::SpellCast
        def should_perform? = you? && spell.creature? && (4..6).cover?(spell.mana_value)

        def call = create_eldrazi_spawn(2)
      end

      # "Whenever you cast a creature spell with mana value 7 or greater, draw three cards."
      class DrawTrigger < TriggeredAbility::SpellCast
        def should_perform? = you? && spell.creature? && spell.mana_value >= 7

        def call = draw_cards(3)
      end

      def event_handlers
        { Events::SpellCast => [SpawnTrigger, DrawTrigger] }
      end
    end
  end
end
