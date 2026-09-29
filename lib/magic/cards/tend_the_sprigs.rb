module Magic
  module Cards
    class TendTheSprigs < Sorcery
      card_name "Tend the Sprigs"
      cost generic: 2, green: 1

      TreefolkToken = Token.create "Treefolk" do
        creature_type "Treefolk"
        power 3
        toughness 4
        colors :green
        keywords :reach
      end

      class SearchChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor:, to_zone: :battlefield, enters_tapped: true, upto: 1, filter: Filter[:basic_lands])
        end

        # "Then if you control seven or more lands and/or Treefolk, create a 3/4 green Treefolk
        # creature token with reach."
        def resolve!(targets:)
          super
          return unless controller.permanents.count { _1.land? || _1.type?("Treefolk") } >= 7

          trigger_effect(:create_token, token_class: TreefolkToken)
        end
      end

      def resolve!
        game.choices.add(SearchChoice.new(actor: self))
      end
    end
  end
end
