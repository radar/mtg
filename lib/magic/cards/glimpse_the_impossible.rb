module Magic
  module Cards
    GlimpseTheImpossible = Sorcery("Glimpse the Impossible") do
      cost generic: 2, red: 1
    end

    class GlimpseTheImpossible < Sorcery
      # "At the beginning of the next end step, if any of those cards remain exiled, put them into your graveyard, then
      # create a 0/1 colorless Eldrazi Spawn creature token for each card put into your graveyard this way." A
      # game-level listener that removes itself once it has fired.
      class CleanUpLater
        def initialize(game:, source:, cards:)
          @game = game
          @source = source
          @cards = cards
        end

        def receive_event(event)
          return unless event.is_a?(Events::BeginningOfEndStep)

          @game.unsubscribe(self)
          remaining = @cards.select { _1.zone&.exile? }
          return if remaining.empty?

          remaining.each { _1.move_to_graveyard! }
          @source.create_eldrazi_spawn(remaining.size)
        end
      end

      # "Exile the top three cards of your library. You may play those cards this turn."
      def resolve!
        cards = controller.library.cards.first(3)
        cards.each do |card|
          card.exile!
          game.play_permissions.grant_until_end_of_turn(card:, player: controller)
        end
        game.subscribe(CleanUpLater.new(game:, source: self, cards:))
      end
    end
  end
end
