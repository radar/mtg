module Magic
  module Cards
    TempleOfTheFalseGod = Card("Temple of the False God") { type "Land" }

    class TempleOfTheFalseGod < Card
      # "{T}: Add {C}{C}. Activate only if you control five or more lands."
      class ManaAbility < Magic::TapManaAbility
        choices :colorless

        def mana_produced = { colorless: 2 }

        def requirements_met?
          source.controller.lands.count >= 5
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
