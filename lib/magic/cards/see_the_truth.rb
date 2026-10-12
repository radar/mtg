module Magic
  module Cards
    class SeeTheTruth < Sorcery
      card_name "See the Truth"
      cost generic: 1, blue: 1

      # "Look at the top three cards of your library. Put one of those cards into your hand and the rest on the bottom
      # of your library in any order." The rest go to the bottom in a random order, as for every look-at-the-top choice.
      # "If this spell was cast from anywhere other than your hand, put each of those cards into your hand instead."
      def resolve!
        if zone&.hand? || zone.nil?
          game.add_choice(Magic::Choice::LookAtTopCards.new(actor: self, amount: 3, filter: nil))
        else
          controller.library.first(3).each(&:move_to_hand!)
        end
      end
    end
  end
end
