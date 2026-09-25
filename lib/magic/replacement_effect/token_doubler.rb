module Magic
  class ReplacementEffect
    # "If an effect would create one or more tokens under your control, it creates twice
    # that many of those tokens instead." (Doubling Season, Anointed Procession, Parallel Lives)
    #
    # The replacement is a copy of the original effect with a doubled amount, so everything the
    # original effect specified (tapped, attacking, base power/toughness) is true of the extra
    # tokens too (Doubling Season ruling).
    class TokenDoubler < ReplacementEffect
      def applies?(effect)
        effect.controller == receiver.controller
      end

      def call(effect)
        effect.with_amount(effect.amount * 2)
      end
    end
  end
end
