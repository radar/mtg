module Magic
  module Cards
    BurnishedHart = Creature("Burnished Hart") do
      cost generic: 3
      artifact_creature_type("Elk")
      power 2
      toughness 2
    end

    class BurnishedHart < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{3}, Sacrifice {this}"

        def resolve!
          game.choices.add(Magic::Choice::SearchLibrary.new(actor: source, to_zone: :battlefield, enters_tapped: true, upto: 2, filter: Filter[:basic_lands]))
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
