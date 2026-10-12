module Magic
  module Cards
    AshBarrens = Card("Ash Barrens") do
      type "Land"
      # "Basic landcycling {1}"
      landcycling({ generic: 1 })
    end

    class AshBarrens < Card
      class ManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
