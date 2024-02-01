module Magic
  module Actions
    class ActivateAbility < Action
      attr_reader :ability, :costs, :targets

      def initialize(ability:, **args)
        @ability = ability
        @costs = @ability.costs
        @targets = []
        super(**args)
      end

      def inspect
        "#<Actions::Actions::ActivateAbility source: #{ability.source.name}, ability: #{ability.class}>"
      end

      def can_be_activated?(player)
        costs.all? { |cost| cost.can_pay?(player) } && @ability.requirements_met?
      end

      def name
        ability
      end

      def valid_targets?(*targets)
        ability.valid_targets?(*targets)
      end

      def targeting(*targets)
        raise "Invalid target specified for #{ability}: #{targets}" unless valid_targets?(*targets)
        @targets = targets
        self
      end

      def pay_mana(payment)
        pay(:mana, payment)
        self
      end

      def pay_tap
        pay(:tap)
      end

      def pay_multi_tap(targets)
        pay(:multi_tap, targets)
      end

      def pay_sacrifice(targets)
        pay(:sacrifice, targets)
      end

      def pay_discard(targets)
        pay(:discard, targets)
      end

      def perform
        resolver = ability.method(:resolve!)
        args = {}
        args[:target] = targets.first if resolver.parameters.include?([:keyreq, :target])
        args[:targets] = targets if resolver.parameters.include?([:keyreq, :targets])
        ability.resolve!(**args)
      end

      def pay(cost_type, payment = nil)
        cost_type = case cost_type
        when :mana
          Costs::Mana
        when :tap
          Costs::Tap
        when :multi_tap
          Costs::MultiTap
        when :discard
          Costs::Discard
        when :sacrifice
          Costs::Sacrifice
        else
          raise "unknown cost type: #{cost_type}"
        end

        cost = costs.find { |cost| cost.is_a?(cost_type) }
        cost.pay(player, payment)

        self
      end

      def has_cost?(cost_type)
        costs.any? { |cost| cost.is_a?(cost_type) }
      end

      def finalize_costs!(player)
        costs.each { |cost| cost.finalize!(player) }
      end
    end
  end
end
