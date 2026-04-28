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

      def countered!
        game.notify!(Events::AbilityCountered.new(ability: ability, player: player))
      end

      def pay_mana(payment)
        pay(:mana, payment)
        self
      end

      def pay_self_tap
        pay(:self_tap)
      end

      def pay_tap(target)
        pay(:tap, target)
      end

      def pay_multi_tap(targets)
        pay(:multi_tap, targets)
      end

      def pay_sacrifice(targets)
        pay(:sacrifice, targets)
      end

      def pay_self_sacrifice
        pay(:self_sacrifice)
      end

      def pay_discard(targets)
        pay(:discard, targets)
      end

      def perform
        game.stack.add(self)

        game.notify!(Events::AbilityActivated.new(ability: ability, player: player, targets: targets))
      end

      def pay(cost_type, payment = nil)
        cost_type = case cost_type
        when :mana
          Costs::Mana
        when :self_tap
          Costs::SelfTap
        when :tap
          Costs::Tap
        when :multi_tap
          Costs::MultiTap
        when :discard
          Costs::Discard
        when :sacrifice
          Costs::Sacrifice
        when :self_sacrifice
          Costs::SelfSacrifice
        else
          raise "unknown cost type: #{cost_type}"
        end

        cost = costs.find { |cost| cost.is_a?(cost_type) }
        raise "Unknown cost: #{cost_type}" if cost.nil?

        if cost.is_a?(Costs::Mana) && any_color_for_creature_activations?
          cost.treat_any_color_as_any!
        end

        pay_method = cost.method(:pay)
        args = {}
        args[:player] = player if pay_method.parameters.include?([:keyreq, :player])
        args[:payment] = payment if pay_method.parameters.include?([:keyreq, :payment])
        cost.pay(**args)

        self
      end

      def any_color_for_creature_activations?
        game.battlefield.static_abilities
          .of_type(Abilities::Static::AnyColorForCreatureActivations)
          .applies_to(ability.source)
          .any?
      end

      def has_cost?(cost_type)
        costs.any? { |cost| cost.is_a?(cost_type) }
      end

      def finalize_costs!(player)
        costs.each { |cost| cost.finalize!(player) }
      end

      def resolve!
        resolve_with_args(ability, target: targets.first, targets: targets)
      end
    end
  end
end
