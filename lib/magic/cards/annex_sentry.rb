module Magic
  module Cards
    AnnexSentry = Creature("Annex Sentry") do
      type artifact_creature_type("Phyrexian Cleric")
      cost white: 1, generic: 2
      power 1
      toughness 4
    end

    class AnnexSentry < Creature
      KEYWORDS = [Keywords::Toxic.new(1)]

      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          cards_to_exile = battlefield.not_controlled_by(controller).cmc_lte(3).by_any_type("Creature", "Artifact")
          cards_to_exile.each do |card|
            exile_effect = Effects::Exile.new(source: permanent).resolve(target: card)
            permanent.exiled_cards << card
          end
        end
      end
    end
  end
end
