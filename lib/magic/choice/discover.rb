module Magic
  class Choice
    # Discover N (rule 701.57): exile cards from the top of your library until you exile a nonland card with mana value
    # N or less. Cast it without paying its mana cost or put it into your hand. Put the rest on the bottom in a random
    # order.
    #
    #   Magic::Choice::Discover.perform(actor: actor, value: 5)
    #
    # Answer the pending choice with `game.resolve_choice!` to cast the card, or `game.skip_choice!` to put it into your
    # hand. A spell that needs a target asks for it through `Choice::FreeCast`; skipping that choice puts nothing on the
    # stack (the card stays in exile).
    class Discover < May
      def self.perform(actor:, value:)
        controller = actor.controller
        exiled = []
        hit = nil
        while (card = controller.library.first)
          card.exile!
          exiled << card
          if !card.land? && card.mana_value <= value
            hit = card
            break
          end
        end

        exiled.reject { _1 == hit }.shuffle.each do |card|
          card.move_zone!(to: controller.library)
          controller.library.remove(card)
          controller.library.push(card)
        end

        actor.game.choices.add(new(actor: actor, card: hit)) if hit
      end

      attr_reader :card

      def initialize(actor:, card:)
        super(actor: actor)
        @card = card
      end

      def prompt = "Cast #{card.name} without paying its mana cost, or put it into your hand?"

      def resolve!
        FreeCast.start(actor: actor, card: card, exile_after: false)
      end

      def decline!
        card.move_to_hand!(controller)
      end
    end
  end
end
