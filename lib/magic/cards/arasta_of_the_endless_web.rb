module Magic
  module Cards
    ArastaOfTheEndlessWeb = Creature("Arasta of the Endless Web") do
      type "Legendary Enchantment Creature -- Spider"
      cost "{2}{G}{G}"
      power 3
      toughness 5
      keywords :reach
    end

    class ArastaOfTheEndlessWeb < Creature
      SpiderToken = Token.create "Spider" do
        type "Creature —- Spider"
        power 1
        toughness 2
        keywords :reach
        colors :green
      end

      class SpellCastTrigger < TriggeredAbility::SpellCast
        # Whenever an opponent casts an instant or sorcery spell ...
        def should_perform?
          opponent? && (spell.instant? || spell.sorcery?)
        end

        # ... create a 1/2 green Spider creature token with reach.
        def call
          actor.create_token(token_class: SpiderToken)
        end
      end

      def event_handlers
        {
          Events::SpellCast => SpellCastTrigger
        }
      end
    end
  end
end
