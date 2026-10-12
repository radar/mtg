module Magic
  module Cards
    ShivanGorge = Card("Shivan Gorge") { type T::Super::Legendary, T::Land }

    class ShivanGorge < Card
      class ManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      # "{2}{R}, {T}: Shivan Gorge deals 1 damage to each opponent."
      class PingAbility < Magic::ActivatedAbility
        costs "{2}{R}, {T}"

        def resolve!
          game.opponents(controller).each { trigger_effect(:deal_damage, source: source, target: _1, damage: 1) }
        end
      end

      def activated_abilities = [ManaAbility, PingAbility]
    end
  end
end
