module Magic
  module Cards
    TaintedPeak = Card("Tainted Peak") { type "Land" }

    class TaintedPeak < Card
      class ColorlessManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      # "{T}: Add {B} or {R}. Activate only if you control a Swamp."
      class ColoredManaAbility < Magic::TapManaAbility
        choices :black, :red

        def requirements_met?
          source.controller.lands.by_any_type("Swamp").any?
        end
      end

      def activated_abilities = [ColorlessManaAbility, ColoredManaAbility]
    end
  end
end
