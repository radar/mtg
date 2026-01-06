module Magic
  module Abilities
    module Static
      class PowerAndToughnessModification < StaticAbility
        attr_reader :source, :power, :toughness, :applicable_targets

        def self.modify(power:, toughness:)
          define_method(:power_modification) { power } if power
          define_method(:toughness_modification) { toughness } if toughness
        end

        def self.other_creatures(creature_type)
          define_method(:applicable_targets) do
            source.controller.creatures.by_type(creature_type) - [source]
          end
        end

        def self.creatures_you_control
          define_method(:applicable_targets) do
            source.controller.creatures
          end
        end

        def power_modification
          0
        end

        def toughness_modification
          0
        end

        def applies_to?(permanent)
          binding.pry if $RYAN
          applicable_targets.include?(permanent)
        end
      end
    end
  end
end
