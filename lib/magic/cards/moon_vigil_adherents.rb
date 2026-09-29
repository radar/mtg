module Magic
  module Cards
    MoonVigilAdherents = Creature("Moon-Vigil Adherents") do
      cost generic: 2, green: 2
      creature_type("Elf Druid")
      keywords :trample
    end

    class MoonVigilAdherents < Creature
      class DynamicPowerAndToughness < Abilities::Static::PowerAndToughnessModification
        def applicable_targets = [source]

        def power_modification
          source.controller.creatures.count + source.controller.graveyard.creatures.count
        end

        alias_method :toughness_modification, :power_modification
      end

      def static_abilities = [DynamicPowerAndToughness]
    end
  end
end
