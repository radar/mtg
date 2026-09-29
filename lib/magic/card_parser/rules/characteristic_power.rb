# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # A characteristic-defining power ("*/4"): "~'s power is equal to the number of colors
      # among permanents you control." The card's base power is 0 and this static ability adds
      # the count, recomputed with continuous effects.
      class CharacteristicPower < Data.define(:count)
        include Rule

        LINE = /\A~'s power is equal to (?<count>[^.]+)\.?\z/i

        def self.parse(line)
          return unless (m = LINE.match(line))

          count = Count.parse(m[:count]) or return
          new(count:)
        end

        def kinds = %i[creature]
        def hook = :static_abilities
        def class_base_name = "CharacteristicPower"

        def class_source(name)
          <<~RUBY
            class #{name} < Abilities::Static::PowerAndToughnessModification
              def applicable_targets = [source]

              def power_modification = #{count}

              def toughness_modification = 0
            end
          RUBY
        end
      end
    end
  end
end
