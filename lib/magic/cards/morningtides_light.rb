module Magic
  module Cards
    class MorningtidesLight < Sorcery
      card_name "Morningtide's Light"
      cost generic: 3, white: 1

      def target_choices = battlefield.creatures

      # "Exile Morningtide's Light."
      def exile_as_it_resolves? = true

      # "At the beginning of the next end step, return those cards to the battlefield tapped under
      # their owners' control." A game-level listener that removes itself once it has fired.
      class ReturnLater
        def initialize(game:, cards:)
          @game = game
          @cards = cards
        end

        def receive_event(event)
          return unless event.is_a?(Events::BeginningOfEndStep)

          @game.unsubscribe(self)
          @cards.each do |card|
            card.resolve!(enters_tapped: true, controller: card.owner) if card.zone&.exile?
          end
        end
      end

      # "Exile any number of target creatures. At the beginning of the next end step, return those
      # cards ... Until your next turn, prevent all damage that would be dealt to you."
      def resolve!(targets: [])
        cards = targets.map(&:card)
        targets.each { trigger_effect(:exile, target: _1) }
        game.subscribe(ReturnLater.new(game:, cards:)) if cards.any?
        controller.prevent_all_damage_until_next_turn!
      end
    end
  end
end
