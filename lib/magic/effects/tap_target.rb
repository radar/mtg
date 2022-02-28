module Magic
  module Effects
    class TapTarget < TargetedEffect
      def resolve(target)
        target.tap!
      end
    end
  end
end
