module Magic
  module Cards
    ShadowbloodRidge = Card("Shadowblood Ridge") { type "Land" }

    class ShadowbloodRidge < Card
      # "{1}, {T}: Add {B}{R}."
      class ManaAbility < Magic::ManaAbility
        costs "{1}, {T}"

        def mana_produced = { black: 1, red: 1 }
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
