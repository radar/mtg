module Magic
  module Cards
    HushwoodVerge = Card("Hushwood Verge") do
      type "Land"
    end

    class HushwoodVerge < Card
      class GreenManaAbility < Magic::TapManaAbility
        choices :green
      end

      class WhiteManaAbility < Magic::TapManaAbility
        choices :white

        def requirements_met?
          source.controller.lands.by_any_type("Forest", "Plains").any?
        end
      end

      def activated_abilities = [GreenManaAbility, WhiteManaAbility]
    end
  end
end
