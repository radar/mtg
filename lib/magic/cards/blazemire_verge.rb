module Magic
  module Cards
    BlazemireVerge = Card("Blazemire Verge") do
      type "Land"
    end

    class BlazemireVerge < Card
      class BlackManaAbility < Magic::TapManaAbility
        choices :black
      end

      class RedManaAbility < Magic::TapManaAbility
        choices :red

        def requirements_met?
          source.controller.lands.by_any_type("Swamp", "Mountain").any?
        end
      end

      def activated_abilities = [BlackManaAbility, RedManaAbility]
    end
  end
end
