module Magic
  module Effects
    class DestroyTarget < SingleTargetAndResolve
      def resolve(target)
        target.destroy!
      end
    end
  end
end
