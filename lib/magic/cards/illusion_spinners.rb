module Magic
  module Cards
    IllusionSpinners = Creature("Illusion Spinners") do
      cost generic: 4, blue: 1
      creature_type "Faerie Wizard"
      power 4
      toughness 3
      keywords :flying
    end

    class IllusionSpinners < Creature
      # "You may cast this spell as though it had flash if you control a Faerie."
      def flash?
        super || game.battlefield.controlled_by(controller || owner).any? { |permanent| permanent.type?("Faerie") }
      end

      # "This creature has hexproof as long as it's untapped."
      class UntappedHexproof < Abilities::Static::KeywordGrant
        keyword_grants Keywords::HEXPROOF

        conditions { source.untapped? }
        applicable_targets { [source] }
      end

      def static_abilities = [UntappedHexproof]
    end
  end
end
