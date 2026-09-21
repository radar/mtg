module Magic
  module Actions
    class ActivateLoyaltyAbility < Action
      attr_reader :ability, :planeswalker, :targets, :x_value

      def initialize(ability:, **args)
        @planeswalker = ability.source
        @ability = ability
        @targets = []
        super(**args)
      end

      def inspect
        "#<Actions::Actions::ActivateLoyaltyAbility planeswalker: #{planeswalker.name}, ability: #{ability.class}>"
      end

      def can_be_activated?(player)
        ability.can_be_activated?(player)
      end

      def name
        ability
      end

      def illegal_reason
        return "#{player.inspect} does not control #{planeswalker.name}" if planeswalker.controller != player
        if !ability.instant_speed? && (reason = sorcery_speed_reason)
        return "loyalty abilities can only be activated at sorcery speed, but #{reason}"
      end

        return "#{planeswalker.name} has already activated a loyalty ability this turn" if activated_this_turn?
        return "#{planeswalker.name} does not have enough loyalty" if planeswalker.loyalty + loyalty_change < 0
      end

      def targeting(*targets)
        @targets = targets
        self
      end

      def value_for_x(value)
        @x_value = value
        self
      end

      def perform
        planeswalker.change_loyalty!(loyalty_change)
        game.notify!(Events::AbilityActivated.new(ability: ability, player: player))
        game.stack.add(self)
      end

      def loyalty_change
        ability.loyalty_change == :X ? -(x_value.to_i) : ability.loyalty_change
      end

      def activated_this_turn?
        game.current_turn.actions.any? do |action|
          action.is_a?(ActivateLoyaltyAbility) && action.planeswalker == planeswalker
        end
      end

      def resolve!
        pool = { target: targets.first, targets: targets }
        pool[:value_for_x] = x_value if x_value
        resolve_with_args(ability, **pool)
      end
    end
  end
end
