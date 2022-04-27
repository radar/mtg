module Magic
  module Effects
    class TapTarget < TargetedEffect
      def resolve
        targets.map(&:tap!)
      end
    end
  end
end
