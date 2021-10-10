module Magic
  module Effects
    class TapTarget < Effect
      def requires_choices?
        true
      end

      def single_choice?
        choices.count == 1
      end

      def resolve(target:)
        target.tap!
      end
    end
  end
end
