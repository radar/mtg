module Magic
  module Cards
    UneasyPartings = Instant("Uneasy Partings") do
      cost generic: 3, blue: 1
    end

    class UneasyPartings < Instant
      def single_target? = true

      def target_choices
        [*game.stack.spells.reject { |spell| spell.card == self }, *battlefield.creatures]
      end

      # "This spell costs {1} less to cast if it targets an attacking nontoken creature."
      def cost_change_for_targets(targets)
        target = targets.first
        return 0 unless target.is_a?(Magic::Permanent) && target.creature? && !target.token?

        game.current_turn.attacks.any? { |attack| attack.attacker == target } ? -1 : 0
      end

      def resolve!(target:)
        game.choices.add(SwatAway::TopOrBottom.new(actor: self, target:))
      end
    end
  end
end
