module Magic
  module Abilities
    module Static
      # "Enchanted creature loses all abilities and is a green Elk creature with base
      # power and toughness 3/3." Overrides characteristics of the targets, each part
      # optional. `ContinuousEffects` applies the types, base power/toughness and
      # ability loss; `Permanent#colors` reads the colours.
      #
      #   class Transformation < Abilities::Static::CharacteristicSetting
      #     applies_to_target
      #     sets_types T::Creature, T::Creatures["Elk"]
      #     sets_colors :green
      #     sets_base_power_and_toughness 3, 3
      #     loses_all_abilities
      #   end
      # Spans layers 3 (loses_all_abilities), 4 (sets_types), 5 (sets_colors) and
      # 7b (sets_base_power_and_toughness) depending which of the DSL macros below
      # a subclass uses -- left untagged with `layer`/`sublayer` since no single
      # label fits; ContinuousEffects reads each set_* method directly instead.
      class CharacteristicSetting < StaticAbility
        attr_reader :source

        def self.sets_types(*types) = define_method(:set_types) { types }
        def self.sets_colors(*colors) = define_method(:set_colors) { colors }

        def self.sets_base_power_and_toughness(power, toughness)
          define_method(:set_base_power) { power }
          define_method(:set_base_toughness) { toughness }
        end

        def self.loses_all_abilities = define_method(:loses_all_abilities?) { true }

        def set_types = nil
        def set_colors = nil
        def set_base_power = nil
        def set_base_toughness = nil
        def loses_all_abilities? = false

        def applies_to?(target)
          applicable_targets.include?(target)
        end
      end
    end
  end
end
