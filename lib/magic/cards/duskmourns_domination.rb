module Magic
  module Cards
    class DuskmournsDomination < Aura
      # Duskmourn's Domination {4}{U}{U}
      # Enchantment — Aura
      # Enchant creature
      # You control enchanted creature.
      # Enchanted creature gets -3/-0 and loses all abilities.

      NAME = "Duskmourn's Domination"
      COST = { generic: 4, blue: 2 }

      enchant "Creature"

      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        target.controller = controller

        super
      end

      # "Enchanted creature gets -3/-0 ..."
      class PowerModification < Abilities::Static::PowerAndToughnessModification
        applies_to_target
        modify power: -3, toughness: 0
      end

      # "... and loses all abilities."
      class LoseAbilities < Abilities::Static::CharacteristicSetting
        applies_to_target
        loses_all_abilities
      end

      def static_abilities = [PowerModification, LoseAbilities]
    end
  end
end
