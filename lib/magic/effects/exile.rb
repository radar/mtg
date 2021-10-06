module Magic
  module Effects
    class Exile < Effect

      def requires_choices?
        true
      end

      def resolve(target:)
        target.exile!
      end
    end
  end
end
