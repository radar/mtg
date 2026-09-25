module Magic
  class Choice
    # "Look at the top N cards of your library. You may reveal a <filter> card from among
    # them and put it into your hand. Put the rest on the bottom of your library in a
    # random order." The cards looked at are fixed when the choice is created.
    class LookAtTopCards < Choice
      attr_reader :amount, :looked_at

      def initialize(actor:, amount:, filter:)
        @amount = amount
        @filter = filter
        super(actor: actor)
        @looked_at = controller.library.first(amount)
      end

      def choices = looked_at.select(&@filter)

      # target: the card to reveal and put into hand, or nil to take none.
      def resolve!(target: nil)
        raise ArgumentError, "#{target.name} is not a valid choice" if target && !choices.include?(target)

        if target
          trigger_effect(:reveal_cards, target: [target])
          target.move_to_hand!
        end

        (looked_at - [target]).shuffle.each do |card|
          controller.library.remove(card)
          controller.library.push(card)
        end
      end
    end
  end
end
