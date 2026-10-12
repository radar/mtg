module Magic
  module Cards
    OvergrownZealot = Creature("Overgrown Zealot") do
      cost generic: 1, green: 1
      creature_type "Elf Druid"
      power 0
      toughness 4
    end

    class OvergrownZealot < Creature
      # "{T}: Add one mana of any color."
      class AnyColorManaAbility < Magic::TapManaAbility
        choices :all
      end

      # "{T}: Add two mana of any one color. Spend this mana only to turn permanents face up."
      class FaceUpManaAbility < Magic::TapManaAbility
        choices :all

        def mana_produced = { choice => 2 }

        def mana_restriction = ManaRestriction::TurnFaceUp.new
      end

      def activated_abilities = [AnyColorManaAbility, FaceUpManaAbility]
    end
  end
end
