module Magic
  module Cards
    GlyphElemental = Creature("Glyph Elemental") do
      enchantment_creature_type("Elemental")
      cost generic: 1, white: 1
      bestow Costs::Mana.new(generic: 1, white: 1)
      power 2
      toughness 2
    end

    class GlyphElemental < Creature
      # "Enchanted creature gets +1/+1 for each +1/+1 counter on this Aura."
      def enchanted_bonus_per_plus_one_counter = 1

      # Landfall -- Whenever a land you control enters, put a +1/+1 counter on this permanent.
      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform? = you?

        def call
          add_counter("+1/+1")
        end
      end

      def event_handlers = super.merge(Events::Landfall => LandfallTrigger)
    end
  end
end
