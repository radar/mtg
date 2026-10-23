module Magic
  module Cards
    TrickstersElk = Creature("Trickster's Elk") do
      enchantment_creature_type("Elk")
      cost generic: 2, green: 1
      bestow Costs::Mana.new(generic: 1, green: 1)
      power 3
      toughness 3
    end

    class TrickstersElk < Creature
      # "Enchanted creature loses all abilities and is a green Elk creature with base power and toughness 3/3."
      class Transformation < Abilities::Static::CharacteristicSetting
        applies_to_target
        conditions { source.bestowed_now? }
        sets_types T::Creature, T::Creatures["Elk"]
        sets_colors :green
        sets_base_power_and_toughness 3, 3
        loses_all_abilities
      end

      def static_abilities = [Transformation]
    end
  end
end
