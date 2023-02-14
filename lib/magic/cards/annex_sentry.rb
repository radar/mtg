module Magic
  module Cards
    AnnexSentry = Creature("Annex Sentry") do
      type "Artifact Creature -- Phyrexian Cleric"
      cost white: 1, generic: 2
      power 1
      toughness 4
    end

    class AnnexSentry < Creature
      KEYWORDS = [Keywords::Toxic.new(1)]
    end
  end
end
