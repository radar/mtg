module Magic
  module Cards
    ElvenPassage = Card("Elven Passage") do
      type "Land"
    end

    class ElvenPassage < Card
      # "You may behold an Elf. If you do, untap that land."
      class BeholdElfChoice < Magic::Choice::Behold
        def initialize(actor:, land:)
          @land = land
          super(actor: actor, type: "Elf")
        end

        def resolve!(**)
          super
          @land.untap!
        end
      end

      # "Search your library for a basic land card, put it onto the battlefield tapped, then shuffle."
      class BasicLandChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :battlefield, enters_tapped: true, filter: Filter[:basic_lands],
                prompt: "Search your library for a basic land card. It enters the battlefield tapped.")
        end

        def resolve!(targets:)
          result = super
          land = controller.permanents.find { |permanent| targets.any? { |card| permanent.card.equal?(card) } }
          choice = BeholdElfChoice.new(actor: actor, land: land) if land
          game.add_choice(choice) if choice&.candidates&.any?
          result
        end
      end

      # "{T}, Pay 1 life, Sacrifice this land: ..."
      class SearchAbility < Magic::ActivatedAbility
        costs "{T}, Pay 1 life, Sacrifice {this}"

        def resolve!
          game.add_choice(BasicLandChoice.new(actor: source))
        end
      end

      def activated_abilities = [SearchAbility]
    end
  end
end
