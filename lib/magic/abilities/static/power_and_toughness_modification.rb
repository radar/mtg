module Magic
  module Abilities
    module Static
      class PowerAndToughnessModification < StaticAbility
        attr_reader :source, :power, :toughness, :applicable_targets

        def self.modify(power:, toughness:)
          define_method(:power) { power } if power
          define_method(:toughness) { toughness } if toughness
        end

        def self.other_creatures(creature_type)
          define_method(:applicable_targets) do
            source.controller.creatures.by_type(creature_type) - [source]
          end
        end

        def initialize(source:)
          @source = source
        end

        def applies_to?(target)
          applicable_targets.include?(target)
        end
      end
    end
  end
end
