module Magic
  module Cards
    ArenaOfGlory = Card("Arena of Glory") do
      type "Land"
    end

    class ArenaOfGlory < Card
      # "This land enters tapped unless you control a Mountain."
      def enters_tapped? = controller.permanents.by_any_type("Mountain").none?

      # "{T}: Add {R}."
      class ManaAbility < Magic::TapManaAbility
        choices :red
      end

      # "{R}, {T}, Exert this land: Add {R}{R}. If that mana is spent on a creature spell, it gains haste until end of
      # turn."
      class ExertManaAbility < Magic::ManaAbility
        costs "{R}, {T}"

        def mana_produced = { red: 2 }

        # The two mana carry the haste rider, so only a creature spell they are spent on gains haste.
        def mana_restriction = ManaRestriction::HasteForCreatureSpell.new

        def resolve!
          super
          source.cannot_untap_next_turn!
        end
      end

      def activated_abilities = [ManaAbility, ExertManaAbility]
    end
  end
end
