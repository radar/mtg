module Magic
  module Cards
    BilbosGambit = Instant("Bilbo's Gambit") do
      cost generic: 1, white: 1
    end

    class BilbosGambit < Instant
      # "Gift a Treasure": promised as the spell is cast (see Costs::Gift).
      def kicker_cost
        @gift ||= Costs::Gift.new(self)
      end

      def single_target?
        true
      end

      def target_choices
        game.stack.spells.reject { |spell| spell.card == self }
      end

      # "Return target spell to its owner's hand. If the gift was promised, players can't cast spells this turn."
      # A promised gift is given "before its other effects": the opponent creates a Treasure first.
      def resolve!(target:)
        gift = kicker_cost.paid?
        if gift
          opponent = game.opponents(controller).first
          trigger_effect(:create_token, token_class: Tokens::Treasure, controller: opponent, amount: 1)
        end

        game.stack.remove(target)
        target.kicker_cost.reset! if target.respond_to?(:kicker_cost) && target.kicker_cost.respond_to?(:reset!)
        target.card.move_to_hand!(target.card.owner)

        game.players.each { |player| player.limit_spells_this_turn!(0) } if gift
      end
    end
  end
end
