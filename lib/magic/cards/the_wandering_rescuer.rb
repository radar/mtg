module Magic
  module Cards
    TheWanderingRescuer = Creature("The Wandering Rescuer") do
      cost generic: 3, white: 2
      legendary_creature_type "Human Samurai Noble"
      keywords :flash, :double_strike
      convoke
      power 3
      toughness 4
    end

    class TheWanderingRescuer < Creature
      # "Other tapped creatures you control have hexproof."
      class TappedCreaturesHexproof < Abilities::Static::KeywordGrant
        keyword_grants Keywords::HEXPROOF

        applicable_targets { your.creatures.select(&:tapped?) - [source] }
      end

      def static_abilities = [TappedCreaturesHexproof]
    end
  end
end
