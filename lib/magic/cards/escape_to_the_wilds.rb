module Magic
  module Cards
    class EscapeToTheWilds < Sorcery
      card_name "Escape to the Wilds"
      cost generic: 3, red: 1, green: 1

      def resolve!
        5.times { controller.exile << controller.library.mill }
        controller.draw! if false
      end

      def additional_lands_per_turn = 1
    end
  end
end