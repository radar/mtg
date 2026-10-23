module Magic
  class Choice
    # "You may reveal this card from your opening hand. If you do, at the beginning of your first upkeep, ..." (Devourer of
    # Destiny). Accepting (`game.resolve_choice!`) reveals the card and waits for its owner's first upkeep, then calls the
    # card's `opening_hand_reveal_effect(game:, player:)`. `Game#start!` offers it once the opening hands are drawn.
    class RevealFromOpeningHand < May
      # Listens for the owner's first upkeep, acts once, then stops listening.
      class FirstUpkeepListener
        def initialize(game:, card:)
          @game = game
          @card = card
        end

        def receive_event(event)
          return unless event.is_a?(Events::BeginningOfUpkeep) && event.player == @card.owner

          @game.unsubscribe(self)
          @card.opening_hand_reveal_effect(game: @game, player: @card.owner)
        end
      end

      attr_reader :card

      def initialize(card:)
        @card = card
        super(actor: card)
      end

      def chooser = card.owner

      def prompt = "Reveal #{card.name} from your opening hand?"

      def resolve!
        reveal_cards [card]
        game.subscribe(FirstUpkeepListener.new(game: game, card: card))
      end
    end
  end
end
