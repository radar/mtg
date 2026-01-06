module Magic
  module Cards
    RousingRead = Aura("Rousing Read") do
      cost generic: 2, blue: 1


      enters_the_battlefield do
        actor.trigger_effect(:draw_cards, number_to_draw: 2)
        actor.add_choice(:discard)
      end

      def target_choices
        battlefield.creatures
      end

      class KeywordGrantFlying < Abilities::Static::KeywordGrant
        keyword_grants Keywords::FLYING
        applies_to_target
      end

      class RousingReadPowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        applies_to_target
      end

      def static_abilities
        [KeywordGrantFlying, RousingReadPowerAndToughnessModification]
      end
    end
  end
end
