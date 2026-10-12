module Magic
  class Choice
    # "If this card is in your opening hand, you may begin the game with it on the battlefield" (a Leyline). Accepting
    # (`game.resolve_choice!`) puts the card onto the battlefield, declining (`game.skip_choice!`) leaves it in hand.
    # `Game#start!` asks each player in turn order, once the opening hands are drawn.
    class BeginOnBattlefield < May
      attr_reader :card

      def initialize(card:)
        @card = card
        super(actor: card)
      end

      def chooser = card.owner

      def prompt = "Begin the game with #{card.name} on the battlefield?"

      def resolve!
        return unless card.zone&.hand?

        Permanent.put_onto_battlefield(game: game, card: card, from_zone: card.zone, controller: chooser)
      end
    end
  end
end
