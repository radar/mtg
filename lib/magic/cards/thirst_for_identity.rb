module Magic
  module Cards
    ThirstForIdentity = Instant("Thirst for Identity") do
      cost generic: 2, blue: 1
    end

    class ThirstForIdentity < Instant
      # "Then discard two cards unless you discard a creature card": either one
      # creature card, or two cards (all of them, with fewer than two in hand).
      class DiscardChoice < Magic::Choice
        class InvalidDiscard < StandardError; end

        def choices = hand.cards

        def resolve!(cards:)
          raise InvalidDiscard, "discard one creature card or two cards" unless valid?(cards)

          cards.each(&:discard!)
        end

        private

        def valid?(cards)
          return false unless cards.all? { hand.include?(_1) } && cards.uniq.size == cards.size
          return true if cards.one? && cards.first.creature?

          cards.size == [2, hand.count].min
        end
      end

      def resolve!
        trigger_effect(:draw_cards, number_to_draw: 3)
        game.add_choice(DiscardChoice.new(actor: self)) if controller.hand.any?
      end
    end
  end
end
