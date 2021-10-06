module Magic
  module Effects
    class DestroyControllerGainsLife < Effect
      def requires_choices?
        true
      end

      def resolve(target:)
        target.destroy!
        target.controller.gain_life(4)
      end
    end
  end
end
