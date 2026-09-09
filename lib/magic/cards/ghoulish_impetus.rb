module Magic
  module Cards
    GhoulishImpetus = Aura("Ghoulish Impetus") do
      cost generic: 2, black: 1
    end

    class GhoulishImpetus < Aura
      def target_choices
        battlefield.creatures
      end

      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        applies_to_target
      end

      class KeywordGrant < Abilities::Static::KeywordGrant
        keyword_grants Keywords::DEATHTOUCH
        applies_to_target
      end

      def static_abilities = [PowerAndToughnessModification, KeywordGrant]
    end
  end
end