module Magic
  module Cards
    class CruelclawsHeist < Sorcery
      card_name "Cruelclaw's Heist"
      cost black: 2
      gift :card

      class ExileChoice < Magic::Choice
        def initialize(actor:, player:, castable:)
          super(actor: actor)
          @player = player
          @castable = castable
        end

        def choices = @player.hand.cards.reject(&:land?)

        def resolve!(card:)
          raise ArgumentError, "#{card.name} is not a legal choice" unless choices.include?(card)

          exile_target(card)
          game.play_permissions.grant_while_exiled(card: card, player: controller, any_mana: true) if @castable
        end
      end

      def target_choices = game.opponents(controller)

      # Target opponent reveals their hand. You choose a nonland card from it. Exile that card. If the gift was
      # promised, you may cast that card for as long as it remains exiled, and mana of any type can be spent to
      # cast it.
      def resolve!(target:)
        reveal_cards(target.hand.cards.to_a)
        choice = ExileChoice.new(actor: self, player: target, castable: gift_promised?)
        game.choices.add(choice) if choice.choices.any?
      end
    end
  end
end
