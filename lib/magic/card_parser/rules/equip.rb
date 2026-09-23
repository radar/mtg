# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "Equip {2}{R}"
      class Equip < Data.define(:cost)
        include Rule

        LINE = /\AEquip (?<cost>(?:\{[^}]+\})+)\z/

        def self.parse(line)
          return unless (m = LINE.match(line))

          new(cost: ManaCost.parse(m[:cost]))
        end

        def dsl_lines
          ["equip [Costs::Mana.new(#{cost.map { |color, amount| "#{color}: #{amount}" }.join(', ')})]"]
        end
      end
    end
  end
end
