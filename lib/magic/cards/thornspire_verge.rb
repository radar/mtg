module Magic
  module Cards
    ThornspireVerge = Card("Thornspire Verge") do
      type "Land"
    end

    class ThornspireVerge < Card
      class RedManaAbility < Magic::TapManaAbility
        choices :red
      end

      class GreenManaAbility < Magic::TapManaAbility
        choices :green

        def requirements_met?
          source.controller.lands.by_any_type("Mountain", "Forest").any?
        end
      end

      def activated_abilities = [RedManaAbility, GreenManaAbility]
    end
  end
end
