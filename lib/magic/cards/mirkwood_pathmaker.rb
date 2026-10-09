module Magic
  module Cards
    MirkwoodPathmaker = Creature("Mirkwood Pathmaker") do
      cost generic: 2, green: 1
      creature_type "Elf Ranger"
    end

    class MirkwoodPathmaker < Creature
      # "Mirkwood Pathmaker's power and toughness are each equal to the number of lands you control."
      class LandCountPowerAndToughness < Abilities::Static::PowerAndToughnessModification
        def applicable_targets = [source]

        def power_modification
          source.controller.lands.count
        end

        alias_method :toughness_modification, :power_modification
      end

      def static_abilities = [LandCountPowerAndToughness]
    end
  end
end
