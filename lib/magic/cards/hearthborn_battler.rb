module Magic
  module Cards
    HearthbornBattler = Creature("Hearthborn Battler") do
      cost generic: 2, red: 1
      creature_type("Lizard Warlock")
      keywords :haste
      power 2
      toughness 3
    end

    class HearthbornBattler < Creature
      # Whenever a player casts their second spell each turn, this creature deals 2 damage to target opponent.
      class SecondSpellTrigger < TriggeredAbility::SpellCast
        def should_perform? = second_spell_this_turn?

        def call
          opponents.each { |opponent| trigger_effect(:deal_damage, target: opponent, damage: 2) }
        end
      end

      def event_handlers
        handlers = super
        handlers.merge(Events::SpellCast => [*handlers[Events::SpellCast], SecondSpellTrigger])
      end
    end
  end
end
