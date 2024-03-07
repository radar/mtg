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
        def initialize(source:)
          @source = source
        end

        def power
          1
        end

        def toughness
          1
        end

        def applicable_targets
          source.controller.creatures.by_any_type("Dog") - [source]
        end
      end

      def static_abilities = [PowerAndToughnessModification]
    end

  end
end
