module Magic
  module Cards
    AuroraAwakener = Creature("Aurora Awakener") do
      creature_type "Giant Druid"
      cost generic: 6, green: 1
      power 7
      toughness 7
      keywords :trample
    end

    class AuroraAwakener < Creature
      # "Put any number of those permanent cards onto the battlefield, then put the rest of
      # the revealed cards on the bottom of your library in a random order."
      class PutOntoBattlefieldChoice < Magic::Choice
        attr_reader :revealed, :permanent_cards

        def initialize(actor:, revealed:, permanent_cards:)
          super(actor: actor)
          @revealed = revealed
          @permanent_cards = permanent_cards
        end

        def choices = permanent_cards

        # cards: the permanent cards to put onto the battlefield (any number, including none).
        def resolve!(cards: [])
          raise ArgumentError, "not a revealed permanent card" unless (cards - permanent_cards).empty?

          cards.each do |card|
            Permanent.resolve(card: card, game: game, from_zone: card.zone, cast: false, controller: controller)
          end

          (revealed - cards).shuffle.each do |card|
            controller.library.remove(card)
            controller.library.push(card)
          end
        end
      end

      # Vivid -- When this creature enters, reveal cards from the top of your library until you
      # reveal X permanent cards, where X is the number of colors among permanents you control.
      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          x = controller.colors_among_permanents
          revealed = []
          permanent_cards = []
          controller.library.each do |card|
            break if permanent_cards.count >= x

            revealed << card
            permanent_cards << card if card.permanent?
          end
          return if revealed.empty?

          trigger_effect(:reveal_cards, target: revealed)
          game.add_choice(PutOntoBattlefieldChoice.new(actor: actor, revealed: revealed, permanent_cards: permanent_cards))
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
