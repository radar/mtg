module Magic
  module Cards
    GravenCairns = Card("Graven Cairns") { type "Land" }

    class GravenCairns < Card
      # "{T}: Add {C}."
      class ColorlessManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      # "{B/R}, {T}: Add {B}{B}, {B}{R}, or {R}{R}."
      class FilterManaAbility < Magic::ManaAbility
        costs "{B/R}, {T}"

        MANA = { black_black: { black: 2 }, black_red: { black: 1, red: 1 }, red_red: { red: 2 } }.freeze

        def choices = MANA.keys

        def mana_produced = MANA.fetch(choice)
      end

      def activated_abilities = [ColorlessManaAbility, FilterManaAbility]
    end
  end
end
