module Magic
  module Cards
    PackLeader = Creature("Pack Leader") do
      creature_type("Dog")
      power 2
      toughness 2
      cost generic: 1, white: 1
    end

    class PackLeader < Creature
      def replacement_effects
        {
          Effects::DealCombatDamage => -> (receiver, event) do
            # Whenever Pack Leader attacks, prevent all combat damage that would be dealt this turn to Dogs you control.
            if receiver.attacking? && event.target.creature? && event.target.type?(T::Creatures["Dog"])
              Effects::Noop.new(source: receiver)
            else
              event
            end
          end
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
