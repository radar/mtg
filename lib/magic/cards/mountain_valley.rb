module Magic
  module Cards
    MountainValley = Card("Mountain Valley") do
      type "Land"
      enters_tapped
    end

    class MountainValley < Card
      class Choice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :battlefield, filter: ->(card) { card.any_type?("Mountain", "Forest") })
        end
      end

      class Ability < Magic::ActivatedAbility
        costs "{T}, Sacrifice {this}"

        def resolve!
          game.add_choice(Choice.new(actor: source))
        end
      end

      def activated_abilities = [Ability]
    end
  end
end