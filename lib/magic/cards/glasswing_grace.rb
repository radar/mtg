module Magic
  module Cards
    # The land back face of Glasswing Grace. It has no mana cost.
    AgeGracedChapel = Card("Age-Graced Chapel") do
      type "Land"
    end

    class AgeGracedChapel < Card
      def enters_tapped? = true

      class ManaAbility < Magic::TapManaAbility
        choices :white, :black
      end

      def activated_abilities = [ManaAbility]
    end

    GlasswingGrace = Aura("Glasswing Grace") do
      cost "{3}{W/B}{W/B}"
      back_face AgeGracedChapel
    end

    class GlasswingGrace < Aura
      enchant "Creature"

      def target_choices = battlefield.creatures

      # "Enchanted creature gets +2/+2 and has flying and lifelink."
      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 2
        applies_to_target
      end

      class KeywordGrant < Abilities::Static::KeywordGrant
        keyword_grants Keywords::FLYING, Keywords::LIFELINK
        applies_to_target
      end

      def static_abilities = [PowerAndToughnessModification, KeywordGrant]
    end
  end
end
