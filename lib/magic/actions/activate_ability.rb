module Magic
  module Actions
    class ActivateAbility < Action
      attr_reader :ability, :costs, :permanent, :targets

      def initialize(permanent:, ability:, **args)
        @permanent = permanent
        @ability = ability.new(source: permanent)
        @costs = @ability.costs
        @targets = []
        super(**args)
      end

      def inspect
        "#<Actions::Actions::ActivateAbility permanent: #{permanent.name}, ability: #{ability.class}>"
      end

      def can_be_activated?(player)
        ability.can_be_activated?(player)
      end

      def countered?
        false
      end

      def name
        ability
      end

      def targeting(*targets)
        @targets = targets
        self
      end

      def pay_mana(payment)
        pay(player, :mana, payment)
      end

      def perform
        if targets.any?
          ability.resolve!(targets: targets)
        else
          ability.resolve!
        end
      end

      def pay(player, cost_type, payment)
        cost_type = case cost_type
        when :mana
          Costs::Mana
        when :discard
          Costs::Discard
        when :sacrifice
          Costs::Sacrifice
        else
          raise "unknown cost type: #{cost_type}"
        end

        cost = costs.find { |cost| cost.is_a?(cost_type) }
        cost.pay(player, payment)
        costs.each { |cost| cost.finalize!(player) }
      end
    end
  end
end
