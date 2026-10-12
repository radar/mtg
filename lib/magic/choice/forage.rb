module Magic
  class Choice
    # "You may forage. If you do, ..." once the may is accepted: pay a forage (`resolve!(payment:)`, see
    # `Player#forage!`) and run `after_forage`. Subclass it and override `after_forage`.
    class Forage < Magic::Choice
      def possible? = controller.can_forage?

      def resolve!(payment:)
        controller.forage!(payment)
        after_forage
      end

      def after_forage
      end
    end
  end
end
