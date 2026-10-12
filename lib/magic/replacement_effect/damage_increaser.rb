module Magic
  class ReplacementEffect
    # Base of "If <a source you control> would deal damage to <something>, it deals that much damage plus N
    # instead." (Valley Flamecaller's +1, Artist's Talent's +2). Same shape as DamageDoubler: a subclass says
    # `increase`, which sources (`source_applies?`) and recipients (`recipient_applies?`) it covers, and may
    # narrow `registrations` to noncombat damage (`Effects::DealDamage` only).
    class DamageIncreaser < DamageDoubler
      def increase = 1

      private

      def new_damage(damage) = damage + increase
    end
  end
end
