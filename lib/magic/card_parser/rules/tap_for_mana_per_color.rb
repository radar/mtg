# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "{T}: For each color among permanents you control, add one mana of that color."
      class TapForManaPerColor < Data.define
        include Rule

        LINE = /\A\{T\}: For each color among permanents you control, add one mana of that color\.?\z/i

        def self.parse(line)
          new if LINE.match?(line)
        end

        def hook = :activated_abilities
        def class_base_name = "ManaAbility"

        def class_source(name)
          <<~RUBY
            class #{name} < Magic::TapManaAbility
              def resolve!
                colors = source.controller.permanents.flat_map(&:colors).uniq
                source.controller.add_mana(**colors.to_h { [_1, 1] }) if colors.any?
              end
            end
          RUBY
        end
      end
    end
  end
end
