module Magic
  module Cards
    SigilOfTheEmptyThrone = Enchantment("Sigil of the Empty Throne") do
      cost generic: 3, white: 2
    end

    class SigilOfTheEmptyThrone < Enchantment
      AngelToken = Token.create("Angel") do
        creature_type "Angel"
        power 4
        toughness 4
        colors :white
        keywords :flying
      end

      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && enchantment?
        end

        def call
          actor.create_token(token_class: AngelToken)
        end
      end

      def event_handlers
        { Events::SpellCast => SpellCastTrigger }
      end
    end
  end
end