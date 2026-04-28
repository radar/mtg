module Magic
  module Cards
    SetessanTraining = Aura("Setessan Training") do
      cost generic: 1, green: 1

      enters_the_battlefield do
        actor.trigger_effect(:draw_cards, number_to_draw: 1)
      end
    end

    class SetessanTraining < Aura
      def target_choices
        battlefield.controlled_by(controller).creatures
      end

      def static_abilities
        [KeywordGrantTrample, PowerModification]
      end

      class KeywordGrantTrample < Abilities::Static::KeywordGrant
        keyword_grants Keywords::TRAMPLE
        applies_to_target
      end

      class PowerModification < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 0
        applies_to_target
      end
    end
  end
end
