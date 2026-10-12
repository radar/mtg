module Magic
  module Cards
    GrimTutor = Sorcery("Grim Tutor") do
      cost generic: 1, black: 2
    end

    class GrimTutor < Sorcery
      class SearchChoice < Magic::Choice::SearchLibrary
        def resolve!(**args)
          super(**args)
          trigger_effect(:lose_life, target: controller, life: 3)
        end
      end

      def resolve!
        game.choices.add(SearchChoice.new(actor: self, to_zone: :hand, enters_tapped: false, upto: 1, filter: ->(card) { true }))
      end
    end
  end
end
