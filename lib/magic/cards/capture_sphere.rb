module Magic
  module Cards
    class CaptureSphere < Aura
      NAME = "Capture Sphere"
      COST = { generic: 3, white: 1 }
      keywords :flash

      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        target.tap!

        super
      end

      def does_not_untap_during_untap_step?
        true
      end
    end
  end
end
