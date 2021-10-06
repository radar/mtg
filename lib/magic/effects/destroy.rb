module Magic
  module Effects
    class Destroy < Effect
      def requires_choices?
        true
      end

      def single_choice?
        choices.count == 1
      end

      def resolve(target:)
        target.destroy!
      end
    end
  end
end
