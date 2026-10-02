module Magic
  module Cards
    ArchmageOfRunes = Creature("Archmage of Runes") do
      cost generic: 3, blue: 2
      creature_type("Giant Wizard")
      power 3
      toughness 6
    end

    class ArchmageOfRunes < Creature
      class CostReduction < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          super(source:, adjustment: { generic: -1 })
        end

        def applies_to?(card) = card.type?("Instant") || card.type?("Sorcery")
      end

      def static_abilities = [CostReduction]

      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && (spell.type?("Instant") || spell.type?("Sorcery"))
        end

        def call
          trigger_effect(:draw_card)
        end
      end

      def event_handlers = { Events::SpellCast => SpellCastTrigger }
    end
  end
end
