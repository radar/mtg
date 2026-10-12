module Magic
  module Cards
    MagnificentEnd = Instant("Magnificent End") do
      cost generic: 4, white: 1
    end

    class MagnificentEnd < Instant
      def single_target? = true

      def target_choices = battlefield.creatures

      # "This spell costs {3} less to cast if it targets a tapped creature."
      def cost_change_for_targets(targets)
        target = targets.first
        target.is_a?(Magic::Permanent) && target.creature? && target.tapped? ? -3 : 0
      end

      # "Magnificent End deals 5 damage to target creature."
      def resolve!(target:)
        trigger_effect(:deal_damage, target:, damage: 5)
      end
    end
  end
end
