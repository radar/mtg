module Magic
  module Cards
    class PortentOfCalamity < Sorcery
      card_name "Portent of Calamity"
      cost x: 1, blue: 1

      CARD_TYPES = %w[Artifact Creature Enchantment Instant Land Planeswalker Sorcery Battle].freeze

      # After exiling, you may cast a spell from among the exiled cards without paying its mana cost if you
      # exiled four or more cards this way. Then put the rest of the exiled cards into your hand.
      class CastOrKeep < Magic::Choice::May
        def initialize(actor:, exiled:)
          @exiled = exiled
          super(actor: actor)
        end

        class SpellChoice < Magic::Choice::Targeted
          def initialize(actor:, exiled:)
            @exiled = exiled
            super(actor: actor)
          end

          def choices = @exiled.reject(&:land?)

          def choice_amount = 1

          def resolve!(target:)
            Magic::Choice::FreeCast.start(actor: actor, card: target)
            @exiled.each { _1.move_to_hand! if _1.zone&.exile? && _1 != target }
          end
        end

        def resolve!
          choice = SpellChoice.new(actor: actor, exiled: @exiled)
          if choice.choices.any?
            game.add_choice(choice)
          else
            decline!
          end
        end

        def decline!
          @exiled.each { _1.move_to_hand! if _1.zone&.exile? }
        end
      end

      # For each card type, you may exile a card of that type from among the revealed cards. Put the rest into
      # your graveyard.
      class ExileChoice < Magic::Choice
        attr_reader :revealed

        def initialize(actor:, revealed:)
          super(actor: actor)
          @revealed = revealed
        end

        def choices = revealed

        def resolve!(cards: [])
          cards = Array(cards)
          raise ArgumentError, "chosen cards must be revealed" unless (cards - revealed).empty?
          raise ArgumentError, "at most one card for each card type" unless distinct_types?(cards)

          cards.each { exile_target(_1) }
          (revealed - cards).each(&:move_to_graveyard!)
          return if cards.empty?

          if cards.size >= 4
            game.choices.add(CastOrKeep.new(actor: actor, exiled: cards))
          else
            cards.each(&:move_to_hand!)
          end
        end

        private

        # Each chosen card stands for one of its card types, no two for the same type.
        def distinct_types?(cards)
          assign = lambda do |remaining, used|
            return true if remaining.empty?

            card = remaining.first
            types = CARD_TYPES.select { card.type?(_1) } - used
            types.any? { |type| assign.call(remaining.drop(1), used + [type]) }
          end
          assign.call(cards, [])
        end
      end

      # Reveal the top X cards of your library.
      def resolve!(value_for_x:)
        revealed = controller.library.first(value_for_x)
        reveal_cards(revealed) if revealed.any?
        game.choices.add(ExileChoice.new(actor: self, revealed: revealed))
      end
    end
  end
end
