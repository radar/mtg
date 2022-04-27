module Magic
  class Player
    class CastAction
      attr_reader :game, :player, :card, :cost, :targets

      def initialize(game:, player:, card:)
        @game = game
        @player = player
        @card = card
        @cost = Costs::Mana.new(apply_cost_reductions(card))
        @targets = []
      end

      def can_cast?
        return false if card.land? && player.can_play_lands?
        return false unless card.zone.hand?
        return true if cost.zero?

        cost.can_pay?(player)
      end

      def targeting(*targets)
        @targets = targets
        self
      end

      def pay(payment)
        cost.pay(player, payment)
        self
      end

      def perform!
        cost.finalize!(player)
        targets.any? ? card.resolve!(targets: targets) : card.resolve!

        game.notify!(Events::SpellCast.new(spell: card, player: player))
      end

      private

      def apply_cost_reductions(card)
        base_cost = card.cost

        reduce_mana_cost_abilities = game.battlefield.static_abilities
          .of_type(Abilities::Static::ReduceManaCost)
          .applies_to(card)

        reduce_mana_cost_abilities.each_with_object(base_cost) { |ability, cost| ability.apply(cost) }
      end
    end
  end
end
