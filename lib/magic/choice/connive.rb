module Magic
  class Choice
    # "Connives X": draw X cards, then discard X cards, then put a +1/+1 counter on the creature for each nonland card
    # discarded this way. `amount` is how many cards are still to be discarded.
    class Connive < Discard
      def self.add(game:, actor:, amount: 1)
        return if amount.zero?

        player = actor.controller
        actor.trigger_effect(:draw_cards, number_to_draw: amount, player: player)
        discards = [amount, player.hand.count].min
        game.add_choice(new(player: player, actor: actor, amount: discards)) if discards.positive?
      end

      def prompt = "Connive: discard #{amount == 1 ? "a card" : "#{amount} cards"}."

      def resolve!(card: nil, cards: nil)
        chosen = cards || [card]
        super(cards: chosen)
        nonland = chosen.count { !_1.land? }
        actor.trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: nonland) if nonland.positive?
      end
    end
  end
end
