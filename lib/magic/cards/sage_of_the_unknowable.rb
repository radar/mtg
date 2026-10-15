module Magic
  module Cards
    SageOfTheUnknowable = Creature("Sage of the Unknowable") do
      cost generic: 1, blue: 1
      creature_type "Human Wizard"
      power 0
      toughness 4
    end

    class SageOfTheUnknowable < Creature
      # "{T}: Add {C}. Spend this mana only to cast a colorless spell or to activate an ability."
      class ManaAbility < Magic::TapManaAbility
        choices :colorless

        def mana_produced = { colorless: 1 }

        def mana_restriction = ManaRestriction::ColorlessSpellOrAbility.new
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
