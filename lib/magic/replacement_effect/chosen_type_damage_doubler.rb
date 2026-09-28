module Magic
  class ReplacementEffect
    # "Double all damage that sources you control of the chosen type would deal." (Collective
    # Inferno.) The receiver is the permanent that holds the chosen creature type.
    class ChosenTypeDamageDoubler < ReplacementEffect
      def self.registrations = [Effects::DealDamage, Effects::DealCombatDamage].map { |matcher| [matcher, self] }

      def applies?(effect)
        type = receiver.chosen_creature_type
        origin = damage_source(effect)
        return false unless type && origin.respond_to?(:type?)

        origin.controller == receiver.controller && origin.type?(type)
      end

      def call(effect)
        effect.dup.tap { |doubled| doubled.instance_variable_set(:@damage, effect.damage * 2) }
      end

      private

      # A creature, or the spell/ability behind the effect.
      def damage_source(effect)
        source = effect.source
        source.respond_to?(:type?) ? source : (source.source if source.respond_to?(:source))
      end
    end
  end
end
