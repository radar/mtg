module Magic
  module Cards
    TaintedWood = Card("Tainted Wood") do
      type "Land"
    end

    class TaintedWood < Card
      class ColorlessManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      class ColoredManaAbility < Magic::TapManaAbility
        choices :black, :green

        def requirements_met?
          source.controller.lands.by_any_type("Swamp").any?
        end
      end

      def activated_abilities = [ColorlessManaAbility, ColoredManaAbility]
    end
  end
end