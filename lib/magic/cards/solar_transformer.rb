module Magic
  module Cards
    SolarTransformer = Artifact("Solar Transformer") do
      cost generic: 2
    end

    class SolarTransformer < Artifact
      # "This artifact enters tapped."
      def enters_tapped? = true

      # When this artifact enters, you get {E}{E}{E}.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          gain_energy 3
        end
      end

      # {T}: Add {C}.
      class ColorlessManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      # {T}, Pay {E}: Add one mana of any color.
      class AnyColorManaAbility < Magic::ManaAbility
        costs "{T}, Pay {E}"

        choices :all
      end

      def etb_triggers = [EntersTrigger]

      def activated_abilities = [ColorlessManaAbility, AnyColorManaAbility]
    end
  end
end
