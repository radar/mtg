module Magic
  module Cards
    LothoCorruptShirriff = Creature("Lotho, Corrupt Shirriff") do
      cost white: 1, black: 1
      legendary_creature_type "Halfling Rogue"
      power 2
      toughness 1
    end

    class LothoCorruptShirriff < Creature
      # "Whenever a player casts their second spell each turn, you lose 1 life and create a Treasure token."
      class SecondSpellTrigger < TriggeredAbility::SpellCast
        def should_perform? = second_spell_this_turn?

        def call
          lose_life(controller, 1)
          create_token(token: Tokens::Treasure, controller:)
        end
      end

      def event_handlers = super.merge({ Events::SpellCast => SecondSpellTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
