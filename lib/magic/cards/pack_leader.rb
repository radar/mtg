module Magic
  module Cards
    class PackLeader < Creature
      card_name "Pack Leader"
      creature_type "Dog"
      power 2
      toughness 2
      cost generic: 1, white: 1

      class PreventCombatDamage < ReplacementEffect
        def applies?(effect)
          receiver.attacking? && effect.target.creature? && effect.target.type?(T::Creatures["Dog"])
        end

        def call(effect)
          Effects::Noop.new(source: receiver)
        end
      end

      def replacement_effects
        {
          Effects::DealCombatDamage => PreventCombatDamage
        }
      end

      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        applicable_targets { source.controller.creatures.all("Dog").except(source) }
      end

      def static_abilities = [PowerAndToughnessModification]
    end

  end
end
