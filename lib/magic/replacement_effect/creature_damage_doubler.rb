module Magic
  class ReplacementEffect
    # "If a creature you control would deal damage to a permanent or player, it deals double that damage instead."
    # (Gratuitous Violence.) Only creatures: your spells' damage isn't doubled.
    class CreatureDamageDoubler < DamageDoubler
      private

      def source_applies?(origin) = origin.is_a?(Magic::Permanent) && origin.creature?
    end
  end
end
