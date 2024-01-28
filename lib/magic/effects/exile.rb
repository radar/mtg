module Magic
  module Effects
    class Exile < TargetedEffect
      def resolve!
        target.exile!
      end
    end
  end
end
