module Magic
  module Effects
    class Exile < Effect

      def requires_choices?
        true
      end

      def resolve(*targets)
        targets.each(&:exile!)
      end
    end
  end
end
