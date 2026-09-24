module Magic
  module Cards
    KenrithsTransformation = Aura("Kenrith's Transformation") do
      cost generic: 1, green: 1

      enters_the_battlefield do
        actor.trigger_effect(:draw_cards, number_to_draw: 1)
      end
    end

    class KenrithsTransformation < Aura
      enchant "Creature"

      def target_choices
        battlefield.creatures
      end

      def static_abilities = [Transformation]

      # Enchanted creature loses all abilities and is a green Elk creature with base
      # power and toughness 3/3.
      class Transformation < Abilities::Static::CharacteristicSetting
        applies_to_target
        sets_types T::Creature, T::Creatures["Elk"]
        sets_colors :green
        sets_base_power_and_toughness 3, 3
        loses_all_abilities
      end
    end
  end
end
