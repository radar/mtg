module Magic
  class ReplacementEffect
    # "If that creature would die this turn, exile it instead." Registered on the permanent
    # itself with Permanent#register_turn_replacement, so it lapses at end of turn.
    class ExileInsteadOfDying < ReplacementEffect
      def applies?(effect)
        effect.target == receiver && !!effect.from&.battlefield? && effect.to.graveyard?
      end

      def call(effect)
        Effects::ExilePermanent.new(source: receiver, target: effect.target)
      end
    end
  end
end
