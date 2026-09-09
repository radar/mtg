module Magic
  module Cards
    EscapeTunnel = Card("Escape Tunnel") do
      type "Land"
    end

    class EscapeTunnel < Card
      class BasicLandChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :battlefield, enters_tapped: true, filter: Filter[:basic_lands])
        end
      end

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