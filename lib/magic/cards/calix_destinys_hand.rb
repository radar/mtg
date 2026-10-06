module Magic
  module Cards
    class CalixDestinysHand < Planeswalker
      card_name "Calix, Destiny's Hand"
      planeswalker "Calix"
      cost generic: 2, green: 1, white: 1
      loyalty 4

      # +1: Look at the top four cards of your library. You may reveal an enchantment card from among them and put that
      # card into your hand. Put the rest on the bottom of your library in a random order.
      class LoyaltyAbility1 < LoyaltyAbility
        def loyalty_change = 1
        def description = "Look at the top four cards of your library. You may reveal an enchantment card from among them and put that card into your hand. Put the rest on the bottom of your library in a random order."

        def resolve!
          choice = Magic::Choice::LookAtTopCards.new(actor: source, amount: 4, filter: ->(card) { card.enchantment? })
          # With nothing to reveal there is nothing to choose, but the cards still go to the bottom.
          choice.choices.empty? ? choice.resolve! : game.choices.add(choice)
        end
      end

      # Returns the exiled permanent's card when the enchantment it was exiled "until" leaves the battlefield.
      # A game-level listener that removes itself once it has fired (see Morningtide's Light).
      class ReturnWhenLeaves
        def initialize(game:, card:, enchantment:)
          @game = game
          @card = card
          @enchantment = enchantment
        end

        def receive_event(event)
          return unless event.is_a?(Events::LeftTheBattlefield) && event.permanent == @enchantment

          @game.unsubscribe(self)
          @card.return_to_battlefield! if @card.zone&.exile?
        end
      end

      # −3: Exile target creature or enchantment you don't control until target enchantment you control leaves the
      # battlefield.
      class LoyaltyAbility2 < LoyaltyAbility
        def loyalty_change = -3
        def description = "Exile target creature or enchantment you don't control until target enchantment you control leaves the battlefield."

        def multi_target? = true

        def target_choices
          [
            battlefield.not_controlled_by(controller).by_any_type(T::Creature, T::Enchantment),
            battlefield.controlled_by(controller).enchantments
          ]
        end

        def resolve!(targets:)
          exiled, enchantment = targets
          # If the enchantment has already left, the "until" has already ended: nothing is exiled.
          return unless enchantment.zone&.battlefield?

          card = exiled.card
          trigger_effect(:exile, source: source, target: exiled)
          game.subscribe(ReturnWhenLeaves.new(game: game, card: card, enchantment: enchantment))
        end
      end

      # −7: Return all enchantment cards from your graveyard to the battlefield.
      class LoyaltyAbility3 < LoyaltyAbility
        def loyalty_change = -7
        def description = "Return all enchantment cards from your graveyard to the battlefield."

        def resolve!
          graveyard.cards.enchantments.each(&:resolve!)
        end
      end

      def loyalty_abilities = [LoyaltyAbility1, LoyaltyAbility2, LoyaltyAbility3]
    end
  end
end
