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

        def resolve!
          super
          source.cannot_untap_next_turn!
          controller.grant_haste_mana!
        end
      end

      def activated_abilities = [ManaAbility, ExertManaAbility]
    end
  end
end
