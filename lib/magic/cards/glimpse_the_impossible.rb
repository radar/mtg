module Magic
  module Cards
    GlimpseTheImpossible = Sorcery("Glimpse the Impossible") do
      cost generic: 2, red: 1
    end

    class GlimpseTheImpossible < Sorcery
      # "At the beginning of the next end step, if any of those cards remain exiled, put them into your graveyard, then
      # create a 0/1 colorless Eldrazi Spawn creature token for each card put into your graveyard this way." A
      # delayed triggered ability (CR 603.7): it goes on the stack at the end step, and the "if" is checked both when it
      # triggers and when it resolves (CR 603.4).
      class EndStepTrigger < TriggeredAbility
        attr_accessor :cards

        def remaining = cards.select { _1.zone&.exile? }

        def should_perform? = remaining.any?

        def call
          moved = remaining
          moved.each { _1.move_to_graveyard! }
          actor.create_eldrazi_spawn(moved.size) if moved.any?
        end
      end

      # A game-level listener that fires the trigger once, at the next end step, then removes itself.
      class EndStepListener
        def initialize(game:, source:, cards:)
          @game = game
          @source = source
          @cards = cards
        end

        def receive_event(event)
          return unless event.is_a?(Events::BeginningOfEndStep)

          @game.unsubscribe(self)
          ability = EndStepTrigger.new(actor: @source, event: event)
          ability.cards = @cards
          return unless ability.trigger!

          @game.queue_triggers? ? @game.queue_trigger!(ability) : ability.call
        end
      end

      # "Exile the top three cards of your library. You may play those cards this turn."
      def resolve!
        cards = controller.library.cards.first(3)
        cards.each do |card|
          card.exile!
          game.play_permissions.grant_until_end_of_turn(card:, player: controller)
        end
        game.subscribe(EndStepListener.new(game:, source: self, cards:))
      end
    end
  end
end
