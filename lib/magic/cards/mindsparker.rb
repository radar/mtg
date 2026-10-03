module Magic
  module Cards
    Mindsparker = Creature("Mindsparker") do
      cost generic: 1, red: 2
      creature_type("Elemental")
      keywords :first_strike
      power 3
      toughness 2
    end

    class Mindsparker < Creature
      class OpponentSpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          opponent? && (spell.colors.include?(:white) || spell.colors.include?(:blue)) && (spell.type?("Instant") || spell.type?("Sorcery"))
        end

        def call
          [that_player].each { trigger_effect(:deal_damage, target: _1, damage: 2) }
        end
      end

      def event_handlers = { Events::SpellCast => OpponentSpellCastTrigger }
    end
  end
end
