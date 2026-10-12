module Magic
  module Cards
    class PartingGust < Instant
      card_name "Parting Gust"
      cost white: 2
      gift :tapped_fish

      def target_choices = battlefield.creatures.reject(&:token?)

      # Exile target nontoken creature. If the gift wasn't promised, return that card to the
      # battlefield under its owner's control with a +1/+1 counter on it at the beginning of the next
      # end step.
      def resolve!(target:)
        card = target.card
        trigger_effect(:exile, target: target)
        game.subscribe(DelayedReturn.new(game: game, cards: [card], counters: { "+1/+1" => 1 })) unless gift_promised?
      end
    end
  end
end
