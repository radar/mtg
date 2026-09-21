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
        can_perform?
      end

      def can_perform?
        illegal_reason.nil?
      end

      def illegal_reason
        return "#{planeswalker.name} is not on the battlefield" unless planeswalker.zone&.battlefield?
        return "#{planeswalker.name} is not controlled by #{player.inspect}" unless planeswalker.controller == player

        if !ability.instant_speed? && (reason = sorcery_speed_reason)
          return "#{planeswalker.name}'s loyalty abilities can only be activated at sorcery speed, but #{reason}"
        end

        return "#{planeswalker.name} has already activated a loyalty ability this turn" if planeswalker.activated_loyalty_ability_turn == game.current_turn.number
        return "#{planeswalker.name} requires an X value" if ability.loyalty_change == :X && x_value.nil?

        loyalty_change = ability.loyalty_change == :X ? -x_value : ability.loyalty_change
        return "#{planeswalker.name} does not have enough loyalty" if loyalty_change.negative? && planeswalker.loyalty < loyalty_change.abs
      end

      def name
        ability
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
        loyalty_change = if ability.loyalty_change == :X
          -(x_value)
        else
          ability.loyalty_change
        end

        planeswalker.change_loyalty!(loyalty_change)
        planeswalker.activated_loyalty_ability_turn = game.current_turn.number
        game.notify!(Events::AbilityActivated.new(ability: ability, player: player))
        game.stack.add(self)
      end

      def resolve!
        pool = { target: targets.first, targets: targets }
        pool[:value_for_x] = x_value if x_value
        resolve_with_args(ability, **pool)
      end
    end
  end
end
