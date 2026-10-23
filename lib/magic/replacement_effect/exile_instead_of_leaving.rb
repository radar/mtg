module Magic
  class ReplacementEffect
    # "If it would leave the battlefield, exile it instead" (unearth). Registered on the permanent with
    # Permanent#register_turn_replacement. Any move off the battlefield is replaced except one into exile.
    class ExileInsteadOfLeaving < ReplacementEffect
      def applies?(effect)
        effect.target == receiver && !!effect.from&.battlefield? && !effect.to.battlefield? && !effect.to.exile?
      end

      def call(effect)
        Effects::ExilePermanent.new(source: receiver, target: effect.target)
      end
    end
  end
end
