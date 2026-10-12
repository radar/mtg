module Magic
  module Cards
    CascadeBluffs = Card("Cascade Bluffs") do
      type "Land"
    end

    class CascadeBluffs < Card
      class ColorlessManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      # {U/R}, {T}: Add {U}{U}, {U}{R} or {R}{R}. The choice names the pair.
      class FilterManaAbility < Magic::ManaAbility
        costs "{U/R}, {T}"

        def choices = %i[blue_blue blue_red red_red]

        def mana_produced
          { blue_blue: { blue: 2 }, blue_red: { blue: 1, red: 1 }, red_red: { red: 2 } }.fetch(choice)
        end
      end

      def activated_abilities = [ColorlessManaAbility, FilterManaAbility]
    end
  end
end
