module Magic
  module Effects
    class DestroyTarget < TargetedEffect
      def resolve!
        target.destroy!
      end
    end
  end
end
