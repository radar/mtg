module Magic
  class ReplacementEffect
    # "If a source you control would deal damage to a permanent or player, it deals triple that damage to that
    # permanent or player instead." (Fiery Emancipation.) Any source of yours, to any recipient.
    class DamageTripler < DamageDoubler
      def call(effect)
        effect.with_damage(effect.damage * 3)
      end
    end
  end
end
