module Magic
  class Player
    class CastAction
      include PayableAction
      attr_reader :game, :player, :card

      def initialize(game:, player:, card:)
        @game = game
        @player = player
        @card = card
        @payment = Hash.new(0)
        @payment[:generic] = {}
      end

      def pay(mana)
        @payment = mana
        @payment[:generic] ||= {}
      end

      def final_cost
        apply_cost_reductions(card)
      end

      def can_cast?
        return false if card.land? && player.can_play_lands?
        return false unless card.zone.hand?
        cost = final_cost
        return true if cost.values.all?(&:zero?)

        pool = player.mana_pool.dup
        color_costs = cost.slice(*Mana::COLORS)

        deduct_from_pool(pool, color_costs)

        generic_mana_payable = pool.values.sum >= cost[:generic]

        generic_mana_payable && (pool.values.all? { |v| v.zero? || v.positive? })
      end

      def cast!
        perform!(final_cost) do
          card.cast!
          player.played_a_land! if card.land?
        end
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
