module Magic
  module Cards
    BalustradeWurm = Creature("Balustrade Wurm") do
      cost generic: 3, green: 2
      creature_type "Wurm"
      keywords :trample, :haste
      cant_be_countered
      power 5
      toughness 5
    end

    class BalustradeWurm < Creature
      # "Delirium -- {2}{G}{G}: Return this card from your graveyard to the battlefield with a finality counter on it.
      # Activate only if there are four or more card types among cards in your graveyard and only as a sorcery."
      class GraveyardAbility < Magic::ActivatedAbility
        costs "{2}{G}{G}"

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
