module Magic
  module Actions
    class ActivateAbility < Action
      attr_reader :permanent, :ability, :costs, :requirements, :targets

      def initialize(permanent:, ability:, **args)
        @permanent = permanent
        @ability = ability.new(source: permanent)
        @costs = @ability.costs
        @requirements = @ability.requirements
        @targets = []
        super(**args)
      end

      def inspect
        "#<Actions::Actions::ActivateAbility permanent: #{permanent.name}, ability: #{ability.class}>"
      end

      def can_be_activated?(player)
        costs.all? { |cost| cost.can_pay?(player) } && requirements.all?(&:call)
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
        self
      end

      def pay_tap
        pay(player, :tap)
      end

      def perform
        if targets.any?
          if ability.single_target?
            ability.resolve!(target: targets.first)
          else
            ability.resolve!(targets: targets)
          end
        else
          ability.resolve!
        end
      end

      def pay(player, cost_type, payment = nil)
        cost_type = case cost_type
        when :mana
          Costs::Mana
        when :tap
          Costs::Tap
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

        self
      end
    end
  end
end
