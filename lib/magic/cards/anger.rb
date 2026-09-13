module Magic
  module Cards
    Anger = Creature("Anger") do
      creature_type "Incarnation"
      cost "{3}{R}"
      power 2
      toughness 2
      keywords :haste
    end

    class Anger < Creature
      class HasteGrant < Abilities::Static::KeywordGrant
        keyword_grants Keywords::HASTE

        applicable_targets { your.creatures }

        conditions { your.lands.by_any_type("Mountain").any? }
      end

      def graveyard_static_abilities = [HasteGrant]
    end
  end
end
