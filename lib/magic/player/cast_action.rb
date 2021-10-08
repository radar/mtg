module Magic
  class Player
    class CastAction
      attr_reader :game, :player, :card, :cost

      def initialize(game:, player:, card:)
        @game = game
        @player = player
        @card = card
        @cost = Costs::Mana.new(cost: apply_cost_reductions(card))
      end

      def can_cast?
        return false if card.land? && player.can_play_lands?
        return false unless card.zone.hand?
        return true if cost.zero?

        cost.can_pay?(player)
      end

      def pay(payment)
        cost.pay(payment)
      end

      def cast!
        cost.finalize!(player)
        card.cast!
        player.played_a_land! if card.land?
      end

      private

      def apply_cost_reductions(card)
        base_cost = card.cost

        reduce_mana_cost_abilities = game.battlefield.static_abilities
          .applies_to(card)
          .select { |ability| ability.is_a?(Abilities::Static::ReduceManaCost) }

        reduce_mana_cost_abilities.each_with_object(base_cost) { |ability, cost| ability.apply(cost) }
      end
    end
  end
end
