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

      # An ability that divides an amount among its targets ("2 damage divided as you choose among one or two
      # targets", Ral, Leyline Prodigy) defines `divided_amount` and `max_divided_targets`. The division is chosen here,
      # on activation, as `distribution: { target => amount }`; a single target takes the whole amount by default.
      def targeting(*targets, distribution: nil)
        raise "Invalid target specified for #{ability}: #{targets}" if ability.respond_to?(:target_choices) && !ability.valid_targets?(*targets)

        if ability.respond_to?(:divided_amount)
          distribution ||= { targets.first => ability.divided_amount } if targets.size == 1
          validate_distribution!(targets, distribution)
          @distribution = distribution
        end

        @targets = targets
        self
      end

      def value_for_x(value)
        @x_value = value
        self
      end

      def perform
        planeswalker.change_loyalty!(loyalty_change)
        game.notify!(Events::AbilityActivated.new(ability: ability, player: player, targets: targets))
        game.stack.add(self)
      end

      def loyalty_change
        ability.loyalty_change == :X ? -(x_value.to_i) : ability.loyalty_change
      end

      def validate_distribution!(targets, distribution)
        valid = distribution &&
          distribution.keys.sort_by(&:object_id) == targets.sort_by(&:object_id) &&
          targets.size.between?(1, ability.max_divided_targets) &&
          distribution.values.all?(&:positive?) &&
          distribution.values.sum == ability.divided_amount
        return if valid

        raise "#{ability.class} must divide #{ability.divided_amount} among 1 to #{ability.max_divided_targets} different targets, at least 1 each: #{distribution.inspect}"
      end

      def activated_this_turn?
        game.current_turn.actions.any? do |action|
          action.is_a?(ActivateLoyaltyAbility) && action.planeswalker == planeswalker
        end
      end

      def resolve!
        pool = { target: targets.first, targets: targets }
        pool[:value_for_x] = x_value if x_value
        pool[:distribution] = @distribution if @distribution
        resolve_with_args(ability, **pool)
      end
    end
  end
end
