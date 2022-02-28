module Magic
  module Effects
    class DestroyControllerGainsLife < TargetedEffect

      def resolve(target)
        target.destroy!
        target.controller.gain_life(4)
      end
    end
  end
end
