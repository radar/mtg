module Magic
  module Cards
    class EvolvingWilds < Land
      NAME = "Evolving Wilds"

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{T}, Sacrifice {this}"

        def resolve!
          game.choices.add(Magic::Choice::SearchLibrary.new(actor: source, to_zone: :battlefield, enters_tapped: true, upto: 1, filter: Filter[:basic_lands]))
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
