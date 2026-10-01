module Magic
  module Cards
    WingbladeDisciple = Creature("Wingblade Disciple") do
      cost generic: 2, blue: 1
      creature_type("Human Monk")
      keywords :flying
      power 2
      toughness 2
    end

    class WingbladeDisciple < Creature
      class FlurryTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && second_spell_this_turn?
        end

        BirdToken = Token.create "Bird" do
          creature_type "Bird"
          power 1
          toughness 1
          colors :white
          keywords :flying
        end

        def call
          trigger_effect(:create_token, token_class: BirdToken)
        end
      end

      def event_handlers = { Events::SpellCast => FlurryTrigger }
    end
  end
end
