module Magic
  module Cards
    WornPowerstone = Artifact("Worn Powerstone") do
      cost generic: 3
    end

    class WornPowerstone < Artifact
      # "This artifact enters tapped."
      def enters_tapped? = true

      # "{T}: Add {C}{C}."
      class ManaAbility < Magic::TapManaAbility
        choices :colorless

        def mana_produced = { colorless: 2 }
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
