module Magic
  module Cards
    # The back face of Needleverge Pathway: played with `play_land(land: card, face: :back)`.
    PillarvergePathway = Card("Pillarverge Pathway") do
      type "Land"
    end

    class PillarvergePathway < Card
      class ManaAbility < Magic::TapManaAbility
        choices :white
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
