module Magic
  module Tokens
    # The colorless Equipment artifact token of Iron Hills Blacksmith: "Equipped creature gets +1/+0" and equip {2}.
    class Axe < Token
      include EquipmentDefaults

      NAME = "Axe"
      POWER = 0
      TOUGHNESS = 0
      type T::Artifact, "Equipment"

      class EquippedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 0
        applies_to_target
      end

      class EquipAbility < Magic::ActivatedAbility
        costs "{2}"

        activate_only_as_sorcery

        def target_choices
          creatures_you_control
        end

        def equip? = true

        def resolve!(target:)
          source.attach_to!(target)
        end
      end

      def static_abilities = [EquippedCreatureBuff]
      def activated_abilities = [EquipAbility]
    end
  end
end
