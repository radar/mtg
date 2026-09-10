module Magic
  module Cards
    AbominationOfLlanowar = Creature("Abomination of Llanowar") do
      legendary_creature_type "Elf Horror"
      cost generic: 1, black: 1, green: 1
      keywords :vigilance, :menace
    end

    class AbominationOfLlanowar < Creature
      class DynamicPowerAndToughness < Abilities::Static::PowerAndToughnessModification
        def applicable_targets = [source]

        def power_modification
          source.controller.permanents.by_any_type("Elf").count + source.controller.graveyard.by_any_type("Elf").count
        end

        alias_method :toughness_modification, :power_modification
      end

      def static_abilities = [DynamicPowerAndToughness]
    end
  end
end
