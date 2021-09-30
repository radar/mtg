module Magic
  class Player
    class CastAction
      attr_reader :game, :player, :card
      def initialize(game:, player:, card:)
        @game = game
        @player = player
        @card = card
      end

      def can_cast?
        return false unless card.zone.hand?

        cost = apply_cost_reductions(card.cost.dup)
        return true if cost.all? { |_color, cost| cost == 0 }

        pool = player.mana_pool.dup
        cost.except(:colorless).each do |color, count|
          pool[color] -= count
        end

        colorless_mana_payable = card.cost[:colorless].nil? || pool.any? { |_, count| count >= card.cost[:colorless] }
        all_above_zero = pool.all? { |_, count| count >= 0 }


        colorless_mana_payable && all_above_zero
      end

      private

      def apply_cost_reductions(base_cost)
        reduce_mana_cost_abilities = game.battlefield.static_abilities.select do |ability|
          ability.is_a?(Abilities::Static::ReduceManaCost)
        end

        reduced_cost = reduce_mana_cost_abilities.each_with_object(base_cost) { |ability, cost| ability.apply(cost) }
        reduced_cost
      end
    end
  end
end
