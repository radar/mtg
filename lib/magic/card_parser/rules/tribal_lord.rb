# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "Other Elves you control get +1/+1." for any creature type.
      class TribalLord < Data.define(:creature_type, :power, :toughness)
        include Rule

        LINE = %r{\AOther (?<type>[A-Z][\w-]*) you control get (?<power>[+-]\d+)/(?<toughness>[+-]\d+)\.?\z}

        def self.parse(line)
          return unless (m = LINE.match(line))

          new(creature_type: CreatureType.singular(m[:type]), power: m[:power].to_i, toughness: m[:toughness].to_i)
        end

        def hook = :static_abilities
        def class_base_name = "PowerAndToughnessModification"

        def class_source(name)
          <<~RUBY
            class #{name} < Abilities::Static::PowerAndToughnessModification
              modify power: #{power}, toughness: #{toughness}
              other_creatures #{creature_type.inspect}
            end
          RUBY
        end
      end
    end
  end
end
