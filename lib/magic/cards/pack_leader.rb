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
          Events::CombatDamageDealt => -> (receiver, event) do
            if receiver.attacking? && event.target.is_a?(Permanent) && event.target.type?(T::Creatures["Dog"])
              return nil
            else
              event
            end
          end
        }
      end

      class CreaturesGetBuffed < Abilities::Static::CreaturesGetBuffed
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

      def static_abilities = [CreaturesGetBuffed]
    end

  end
end
