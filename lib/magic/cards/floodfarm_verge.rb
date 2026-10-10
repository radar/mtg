module Magic
  module Cards
    FloodfarmVerge = Card("Floodfarm Verge") do
      type "Land"
    end

    class FloodfarmVerge < Card
      class WhiteManaAbility < Magic::TapManaAbility
        choices :white
      end

      class BlueManaAbility < Magic::TapManaAbility
        choices :blue

        def requirements_met?
          source.controller.lands.by_any_type("Plains", "Island").any?
        end
      end

      def activated_abilities = [WhiteManaAbility, BlueManaAbility]
    end
  end
end
