module Magic
  module Actions
    class Cast < Action
      attr_reader :card, :targets
      def initialize(card:, **args)
        @card = card
        @targets = []
        super(**args)
      end

      def inspect
        "#<Actions::Cast card: #{card.name}, mana: #{mana_cost.inspect}, player: #{player.inspect}>"
      end

      def mana_cost
        @mana_cost ||= begin
          reduce_mana_cost_abilities = game.battlefield.static_abilities
          .of_type(Abilities::Static::ReduceManaCost)
          .applies_to(card)

          reduce_mana_cost_abilities.each_with_object(card.cost) { |ability, cost| ability.apply(cost) }
        end
      end

      def can_perform?
        return false if card.land? && player.can_play_lands?
        return false unless card.zone.hand?
        return true if mana_cost.zero?

        mana_cost.can_pay?(player)
      end

      def targeting(*targets)
        @targets = targets
        self
      end

      def pay_mana(payment)
        mana_cost.pay(player, payment)
      end

      def perform
        mana_cost.finalize!(player)
        targets.any? ? card.resolve!(targets: targets) : card.resolve!

        game.notify!(Events::SpellCast.new(spell: card, player: player))
      end
    end
  end
end
