module Magic
  module Cards
    class PlanarGenesis < Instant
      card_name "Planar Genesis"
      cost green: 1, blue: 1

      # Shared by both steps: the cards looked at, and the rest going to the bottom in a random order.
      module BottomsTheRest
        attr_reader :looked_at

        def choices = looked_at

        private

        def bottom(cards)
          cards.shuffle.each do |card|
            chooser.library.remove(card)
            chooser.library.push(card)
          end
        end
      end

      # "If you don't, put a card from among them into your hand." Mandatory, so declining only bottoms the cards.
      class HandChoice < Magic::Choice
        include BottomsTheRest

        def initialize(actor:, looked_at:)
          super(actor: actor)
          @looked_at = looked_at
        end

        def resolve!(target:)
          raise ArgumentError, "#{target.name} is not a valid choice" unless choices.include?(target)

          target.move_to_hand!
          bottom(looked_at - [target])
        end

        def decline!
          bottom(looked_at)
        end
      end

      # "You may put a land card from among them onto the battlefield tapped." Declining moves on to the hand choice.
      class LandChoice < Magic::Choice::May
        include BottomsTheRest

        def initialize(actor:, looked_at:)
          super(actor: actor)
          @looked_at = looked_at
          @lands = looked_at.select(&:land?)
        end

        def choices = @lands

        def resolve!(target:)
          raise ArgumentError, "#{target.name} is not a valid choice" unless choices.include?(target)

          Permanent.put_onto_battlefield(card: target, game: game, from_zone: target.zone, controller: chooser, enters_tapped: true)
          bottom(looked_at - [target])
        end

        def decline!
          game.choices.add(HandChoice.new(actor: actor, looked_at: looked_at))
        end
      end

      # Look at the top four cards of your library.
      def resolve!
        looked_at = controller.library.first(4)
        return if looked_at.empty?

        choice = LandChoice.new(actor: self, looked_at: looked_at)
        if choice.choices.any?
          game.choices.add(choice)
        else
          choice.decline!
        end
      end
    end
  end
end
