module Magic
  module Cards
    RiteOfTheDragoncaller = Enchantment("Rite of the Dragoncaller") do
      cost generic: 4, red: 2
    end

    class RiteOfTheDragoncaller < Enchantment
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && (spell.type?("Instant") || spell.type?("Sorcery"))
        end

        DragonToken = Token.create "Dragon" do
          creature_type "Dragon"
          power 5
          toughness 5
          colors :red
          keywords :flying
        end

        def call
          trigger_effect(:create_token, token_class: DragonToken)
        end
      end

      def event_handlers = { Events::SpellCast => SpellCastTrigger }
    end
  end
end
