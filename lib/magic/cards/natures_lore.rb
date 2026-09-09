module Magic
  module Cards
    class NaturesLore < Sorcery
      card_name "Nature's Lore"
      cost generic: 1, green: 1

      class Choice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :battlefield, filter: ->(card) { card.any_type?("Forest") })
        end
      end

      def resolve!
        game.add_choice(Choice.new(actor: self))
      end
    end
  end
end