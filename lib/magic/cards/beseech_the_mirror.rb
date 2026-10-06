module Magic
  module Cards
    class BeseechTheMirror < Sorcery
      card_name "Beseech the Mirror"
      cost generic: 1, black: 3

      # Bargain: you may sacrifice an artifact, enchantment, or token as you cast this spell (`pay_kicker(permanent)`).
      class BargainCost < Costs::SacrificeKicker
        # What +player+ could sacrifice to bargain.
        def choices_for(player)
          player.permanents.select { |permanent| bargainable?(permanent) }
        end

        def pay(player:, payment:)
          raise ArgumentError, "Bargain needs an artifact, enchantment or token to sacrifice, not #{payment.name}" unless bargainable?(payment)

          super
        end

        private

        def bargainable?(permanent)
          permanent.artifact? || permanent.enchantment? || permanent.token?
        end
      end

      def kicker_cost
        @bargain_cost ||= BargainCost.new
      end

      def bargained? = kicker_cost.paid?

      # "You may cast the exiled card without paying its mana cost if that spell's mana value is 4 or less. Put the exiled
      # card into your hand if it wasn't cast this way."
      class CastExiledChoice < Magic::Choice::May
        attr_reader :card

        def initialize(actor:, card:)
          @card = card
          super(actor: actor)
        end

        def resolve!
          controller.cast(card: card, by_effect: true) { _1.mana_cost = 0 }
        end

        def decline!
          card.move_to_hand!
        end
      end

      # "Search your library for a card, exile it face down, then shuffle."
      class SearchChoice < Magic::Choice
        attr_reader :choices

        def initialize(actor:)
          @choices = actor.controller.library.cards
          super
        end

        def resolve!(target:)
          target.exile!
          controller.shuffle!
          if actor.bargained? && target.mana_value <= 4 && !target.land?
            game.add_choice(CastExiledChoice.new(actor: actor, card: target))
          else
            target.move_to_hand!
          end
        end
      end

      def resolve!
        game.add_choice(SearchChoice.new(actor: self))
      end
    end
  end
end
