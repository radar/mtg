module Magic
  module Effects
    class Tap < TargetedEffect

      def resolve!
        target.tap!
      end
    end
  end
end
