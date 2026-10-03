module Magic
  class Choice
    # "Target opponent reveals their hand. You choose a nonland card from it. That player discards that
    # card." (Duress, Pilfer). The actor's controller picks (`resolve!(card:)`) among the cards of `player`'s
    # hand that aren't one of the excluded types; `player` discards it.
    class DiscardFromRevealedHand < Magic::Choice
      attr_reader :player, :excluded_types

      def initialize(actor:, player:, excluded_types: [])
        super(actor: actor)
        @player = player
        @excluded_types = excluded_types
      end

      def choices = player.hand.cards.reject { |card| excluded_types.any? { card.type?(_1) } }

      def resolve!(card:)
        raise ArgumentError, "#{card.name} is not a legal choice" unless choices.include?(card)

        card.move_to_graveyard!
      end
    end
  end
end
