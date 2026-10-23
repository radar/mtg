module Magic
  module Actions
    # Shared by actions whose ability divides an amount among its targets ("2 damage divided as you choose among one or
    # two targets", "3 damage divided as you choose among one, two, or three targets"). The ability defines
    # `divided_amount` and `max_divided_targets`; the division is chosen on activation as `distribution: { target => amount }`.
    module DividedTargeting
      # A single target takes the whole amount by default. Returns the distribution to store, or nil when the ability
      # doesn't divide an amount.
      def divided_distribution(targets, distribution)
        return unless ability.respond_to?(:divided_amount)

        distribution ||= { targets.first => ability.divided_amount } if targets.size == 1
        validate_distribution!(targets, distribution)
        distribution
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
    end
  end
end
