module Magic
  module Cards
    ResurrectedCultist = Creature("Resurrected Cultist") do
      cost generic: 2, black: 1
      creature_type "Human Cleric"
      power 4
      toughness 1
    end

    class ResurrectedCultist < Creature
      # "Delirium -- {2}{B}{B}: Return this card from your graveyard to the battlefield with a finality counter on it.
      # Activate only if there are four or more card types among cards in your graveyard and only as a sorcery."
      class GraveyardAbility < Magic::ActivatedAbility
        costs "{2}{B}{B}"

        def requirements_met?
          source.zone&.graveyard? && source.owner == controller && controller.graveyard.delirium? && game.can_cast_sorcery?(controller)
        end

        def resolve!
          Permanent.put_onto_battlefield(game: game, card: source, from_zone: source.zone, counters: { "finality" => 1 })
        end
      end

      def graveyard_abilities = [GraveyardAbility.new(source: self)]
    end
  end
end
