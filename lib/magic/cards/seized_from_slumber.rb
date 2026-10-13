module Magic
  module Cards
    SeizedFromSlumber = Instant("Seized from Slumber") do
      cost generic: 4, white: 1
    end

    class SeizedFromSlumber < Instant
      def single_target? = true

      def target_choices = battlefield.creatures

      # "This spell costs {3} less to cast if it targets a tapped creature."
      def cost_change_for_targets(targets)
        target = targets.first
        target.is_a?(Magic::Permanent) && target.creature? && target.tapped? ? -3 : 0
      end

      # "Destroy target creature."
      def resolve!(target:)
        destroy(target)
      end
    end
  end
end
