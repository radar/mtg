module Magic
  class ReplacementEffect
    # Base of "If <a source you control> would deal damage to <something>, it deals double that damage instead."
    # (Gratuitous Violence, Twinflame Tyrant). The receiver is the permanent with the ability. A subclass says
    # which sources (`source_applies?`) and which recipients (`recipient_applies?`) it covers; the replacement is a
    # copy of the damage effect with the amount doubled. Two of them stack (each has its own receiver).
    class DamageDoubler < ReplacementEffect
      def self.registrations = [Effects::DealDamage, Effects::DealCombatDamage].map { |matcher| [matcher, self] }

      def applies?(effect)
        origin = damage_source(effect)
        return false unless origin.respond_to?(:controller) && origin.controller == receiver.controller

        source_applies?(origin) && recipient_applies?(effect.target)
      end

      def call(effect)
        effect.with_damage(effect.damage * 2)
      end

      private

      def source_applies?(_origin) = true

      def recipient_applies?(_target) = true

      # The creature or spell, or the spell/ability behind the effect.
      def damage_source(effect)
        source = effect.source
        source.respond_to?(:controller) ? source : (source.source if source.respond_to?(:source))
      end

      # The player who controls what is being damaged: a player is their own.
      def damaged_player(target)
        target.is_a?(Magic::Player) ? target : target.controller
      end
    end
  end
end
