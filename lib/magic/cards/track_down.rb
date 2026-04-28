module Magic
  module Cards
    TrackDown = Sorcery("Track Down") do
      cost generic: 1, green: 1
    end

    class TrackDown < Sorcery
      class ScryChoice < Magic::Choice::Scry
        def resolve!(**args)
          super(**args)

          top_card = controller.library.first
          return unless top_card

          game.notify!(Events::CardsRevealed.new(cards: [top_card]))

          controller.draw! if top_card.creature? || top_card.land?
        end
      end

      def resolve!
        game.choices.add(ScryChoice.new(actor: self, amount: 3))

        super
      end
    end
  end
end
