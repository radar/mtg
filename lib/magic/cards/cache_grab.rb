module Magic
  module Cards
    class CacheGrab < Instant
      card_name "Cache Grab"
      cost generic: 1, green: 1

      # You may put a permanent card from among the cards milled this way into your hand. If you control a
      # Squirrel or returned a Squirrel card to your hand this way, create a Food token.
      class ReturnChoice < Magic::Choice::ReturnFromAmong
        def resolve!(target: nil)
          super
          squirrel = target&.type?("Squirrel") || controller.permanents.any? { _1.type?("Squirrel") }
          create_token(token:Tokens::Food) if squirrel
        end
      end

      # Mill four cards.
      def resolve!
        milled = controller.mill(4)
        game.choices.add(ReturnChoice.new(actor: self, cards: milled, filter: ->(card) { card.permanent? }))
      end
    end
  end
end
