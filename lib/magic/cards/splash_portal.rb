module Magic
  module Cards
    class SplashPortal < Sorcery
      card_name "Splash Portal"
      cost blue: 1

      def target_choices = battlefield.controlled_by(controller).creatures

      # Exile target creature you control, then return it to the battlefield under its owner's control. If that
      # creature is a Bird, Frog, Otter, or Rat, draw a card.
      def resolve!(target:)
        card = target.card
        draws = %w[Bird Frog Otter Rat].any? { target.type?(_1) }
        trigger_effect(:exile, target: target)
        card.resolve!(controller: card.owner) if card.zone&.exile?
        draw_card if draws
      end
    end
  end
end
