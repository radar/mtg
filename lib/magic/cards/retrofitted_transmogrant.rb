module Magic
  module Cards
    RetrofittedTransmogrant = Creature("Retrofitted Transmogrant") do
      cost black: 1
      artifact_creature_type "Zombie"
      power 1
      toughness 1
    end

    class RetrofittedTransmogrant < Creature
      # "{3}{B}: Return this card from your graveyard to the battlefield tapped with two +1/+1 counters on it."
      class GraveyardAbility < Magic::ActivatedAbility
        costs "{3}{B}"

        def requirements_met?
          source.zone&.graveyard? && source.owner == controller
        end

        def resolve!
          return unless source.zone&.graveyard?

          Permanent.put_onto_battlefield(game: game, card: source, from_zone: source.zone, enters_tapped: true,
                                         counters: { "+1/+1" => 2 })
        end
      end

      def graveyard_abilities = [GraveyardAbility.new(source: self)]
    end
  end
end
