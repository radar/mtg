module Magic
  module Cards
    class BeseechTheMirror < Sorcery
      card_name "Beseech the Mirror"
      cost generic: 1, black: 3

      class SearchChoice < Magic::Choice
        attr_reader :choices

        def initialize(actor:)
          @choices = actor.controller.library.cards
          super
        end

        def resolve!(target:)
          target.move_to_hand!
          controller.shuffle!
        end
      end

      def resolve!
        game.add_choice(SearchChoice.new(actor: self))
      end
    end
  end
end