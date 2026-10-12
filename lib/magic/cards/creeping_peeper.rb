module Magic
  module Cards
    CreepingPeeper = Creature("Creeping Peeper") do
      cost generic: 1, blue: 1
      creature_type "Eye"
      power 2
      toughness 1
    end

    class CreepingPeeper < Creature
      # "{T}: Add {U}. Spend this mana only to cast an enchantment spell, unlock a door, or turn a permanent face up."
      class ManaAbility < Magic::TapManaAbility
        choices :blue

        def mana_restriction = ManaRestriction::EnchantmentDoorOrFaceUp.new
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
