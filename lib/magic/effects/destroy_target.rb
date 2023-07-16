module Magic
  module Effects
    class DestroyTarget < TargetedEffect
      def resolve(*targets)
        targets.each(&:destroy!)
      end
    end
  end
end
