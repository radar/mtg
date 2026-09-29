module Magic
  module Cards
    class NoggleTheMind < Aura
      card_name "Noggle the Mind"
      cost generic: 1, blue: 1
      keywords :flash
      enchant "Creature"

      def target_choices = battlefield.creatures

      # "Enchanted creature loses all abilities and is a colorless Noggle with base power and
      # toughness 1/1."
      class Shrink < Abilities::Static::CharacteristicSetting
        applies_to_target
        sets_types T::Creature, T::Creatures["Noggle"]
        sets_colors
        sets_base_power_and_toughness 1, 1
        loses_all_abilities
      end

      def static_abilities = [Shrink]
    end
  end
end
