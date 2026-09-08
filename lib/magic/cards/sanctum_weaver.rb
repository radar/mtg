module Magic
  module Cards
    SanctumWeaver = Creature("Sanctum Weaver") do
      enchantment_creature_type "Dryad"
      cost generic: 1, green: 1
      power 0
      toughness 2
    end

    class SanctumWeaver < Creature
      class ManaAbility < Magic::TapManaAbility
        choices :all

        def mana_produced
          { choice => source.controller.permanents.enchantments.count }
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end