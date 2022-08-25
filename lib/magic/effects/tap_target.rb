module Magic
  module Effects
    class TapTarget < TargetedEffect
      def resolve
        target.map(&:tap!)
      end
    end
  end
end
