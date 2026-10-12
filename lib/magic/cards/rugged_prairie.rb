module Magic
  module Cards
    RuggedPrairie = Card("Rugged Prairie") do
      type "Land"
    end

    class RuggedPrairie < Card
      class ColorlessManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      # {R/W}, {T}: Add {R}{R}, {R}{W} or {W}{W}. The choice names the pair.
      class FilterManaAbility < Magic::ManaAbility
        costs "{R/W}, {T}"

        def choices = %i[red_red red_white white_white]

        def mana_produced
          { red_red: { red: 2 }, red_white: { red: 1, white: 1 }, white_white: { white: 2 } }.fetch(choice)
        end
      end

      def activated_abilities = [ColorlessManaAbility, FilterManaAbility]
    end
  end
end
