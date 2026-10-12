module Magic
  module Cards
    # A modal double-faced land: its controller plays it as this face or as Pillarverge Pathway
    # (`play_land(land: card, face: :back)`).
    NeedlevergePathway = Card("Needleverge Pathway") do
      type "Land"
      back_face PillarvergePathway
    end

    class NeedlevergePathway < Card
      class ManaAbility < Magic::TapManaAbility
        choices :red
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
