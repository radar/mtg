module Magic
  module Cards
    Reprieve = Instant("Reprieve") do
      cost generic: 1, white: 1
    end

    class Reprieve < Instant
      def single_target? = true

      def target_choices
        game.stack.spells.reject { |spell| spell.card == self }
      end

      # "Return target spell to its owner's hand. Draw a card."
      def resolve!(target:)
        game.stack.remove(target)
        target.card.move_to_hand!(target.card.owner)
        draw_card
      end
    end
  end
end
