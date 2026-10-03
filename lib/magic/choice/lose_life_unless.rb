module Magic
  class Choice
    # "That player loses 5 life unless they discard a card." / "Each opponent loses 3 life unless that player
    # sacrifices a nonland permanent of their choice or discards a card." The affected `player` decides: answer
    # `resolve!(discard: card)` or `resolve!(sacrifice: permanent)`, or decline (`game.skip_choice!`) to lose the life.
    # Something that isn't a legal way out also loses the life.
    class LoseLifeUnless < Magic::Choice::May
      attr_reader :player, :life, :discard, :sacrifice

      def initialize(actor:, player:, life:, discard: false, sacrifice: false)
        super(actor: actor)
        @player = player
        @life = life
        @discard = discard
        @sacrifice = sacrifice
      end

      def discard_choices = discard ? player.hand.cards.to_a : []

      def sacrifice_choices = sacrifice ? player.permanents.reject(&:land?) : []

      def resolve!(discard: nil, sacrifice: nil)
        if discard && discard_choices.include?(discard)
          discard.discard!
        elsif sacrifice && sacrifice_choices.include?(sacrifice)
          sacrifice.sacrifice!
        else
          decline!
        end
      end

      def decline!
        trigger_effect(:lose_life, target: player, life: life)
      end
    end
  end
end
