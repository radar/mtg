module Magic
  module Effects
    class PhaseOut < TargetedEffect

      def resolve!
        target.phase_out!
      end
    end
  end
end
