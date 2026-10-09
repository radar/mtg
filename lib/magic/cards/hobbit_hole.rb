module Magic
  module Cards
    HobbitHole = Card("Hobbit Hole") do
      type "Land"
    end

    class HobbitHole < Card
      # "Halflingcycling {4}"
      landcycling({ generic: 4 }, filter: "Halfling")

      class BasicLandChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :battlefield, enters_tapped: true, filter: Filter[:basic_lands],
                prompt: "Search your library for a basic land card. It enters the battlefield tapped.")
        end
      end

      # "{T}, Sacrifice this land: Search your library for a basic land card, put it onto the battlefield tapped, then
      # shuffle."
      class SearchAbility < Magic::ActivatedAbility
        costs "{T}, Sacrifice {this}"

        def resolve!
          game.add_choice(BasicLandChoice.new(actor: source))
        end
      end

      def activated_abilities = [SearchAbility]
    end
  end
end
