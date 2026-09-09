module Magic
  module Cards
    TaintedField = Card("Tainted Field") do
      type "Land"
    end

    class TaintedField < Card
      class ColorlessManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      class ColoredManaAbility < Magic::TapManaAbility
        choices :white, :black

        def requirements_met?
          source.controller.lands.by_any_type("Swamp").any?
        end
      end

      def activated_abilities = [ColorlessManaAbility, ColoredManaAbility]
    end
  end
end