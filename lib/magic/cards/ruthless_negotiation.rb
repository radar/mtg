module Magic
  module Cards
    class RuthlessNegotiation < Sorcery
      card_name "Ruthless Negotiation"
      cost black: 1
      flashback Costs::Mana.new(generic: 4, black: 1)

      class ExileChoice < Magic::Choice
        def initialize(actor:, player:)
          super(actor: actor)
          @player = player
        end

        def controller = @player

        def choices = @player.hand.cards.to_a

        def resolve!(card:)
          raise ArgumentError, "#{card.name} is not in hand" unless choices.include?(card)

          trigger_effect(:exile, target: card)
        end
      end

      def target_choices = game.opponents(controller)

      # Target opponent exiles a card from their hand. If this spell was cast from a graveyard, draw a card.
      def resolve!(target:)
        from_graveyard = zone&.graveyard?
        game.choices.add(ExileChoice.new(actor: self, player: target)) if target.hand.any?
        trigger_effect(:draw_cards, number_to_draw: 1) if from_graveyard
      end
    end
  end
end
