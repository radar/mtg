module Magic
  module Cards
    class Farseek < Sorcery
      card_name "Farseek"
      cost generic: 1, green: 1

      class Choice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :battlefield, enters_tapped: true, filter: ->(card) { card.any_type?("Plains", "Island", "Swamp", "Mountain") })
        end
      end

      def resolve!
        game.add_choice(Choice.new(actor: self))
      end
    end
  end
end