module Magic
  module Cards
    GloomlakeVerge = Card("Gloomlake Verge") do
      type "Land"
    end

    class GloomlakeVerge < Card
      class BlueManaAbility < Magic::TapManaAbility
        choices :blue
      end

      class BlackManaAbility < Magic::TapManaAbility
        choices :black

        def requirements_met?
          source.controller.lands.by_any_type("Island", "Swamp").any?
        end
      end

      def activated_abilities = [BlueManaAbility, BlackManaAbility]
    end
  end
end
