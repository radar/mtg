module Magic
  class Choice
    # Connive (rule 701.50): the creature's controller draws a card, then discards a card. If a nonland card was
    # discarded, the creature gets a +1/+1 counter. `Connive.add(game:, actor:)` draws and queues the discard (nothing
    # to discard when the hand is empty).
    class Connive < Discard
      def self.add(game:, actor:)
        player = actor.controller
        actor.trigger_effect(:draw_cards, number_to_draw: 1, player: player)
        game.add_choice(new(player: player, actor: actor)) if player.hand.any?
      end

      def prompt = "Connive: discard a card."

      def resolve!(card:)
        card.move_to_graveyard!
        actor.trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: 1) unless card.land?
      end
    end
  end
end
