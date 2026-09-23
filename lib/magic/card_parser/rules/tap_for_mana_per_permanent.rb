# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "{T}: Add {G} for each creature you control." The counted thing can be a
      # permanent kind (creature, land, artifact, permanent) or a creature type
      # ("Elf", "Elves").
      class TapForManaPerPermanent < Data.define(:color, :counted)
        include Rule

        LINE = /\A\{T\}: Add \{(?<symbol>[WUBRGC])\} for each (?<noun>[\w-]+) you control\.?\z/i
        KINDS = { "creature" => "creatures", "land" => "lands", "artifact" => "artifacts", "permanent" => "permanents" }.freeze

        def self.parse(line)
          return unless (m = LINE.match(line))

          color = ManaCost::SYMBOL_TO_COLOR.fetch(m[:symbol].upcase)
          noun = m[:noun].downcase
          new(color:, counted: KINDS[noun] || KINDS[noun.delete_suffix("s")] || CreatureType.singular(m[:noun].capitalize))
        end

        def hook = :activated_abilities
        def class_base_name = "ManaAbility"

        def class_source(name)
          <<~RUBY
            class #{name} < Magic::TapManaAbility
              def resolve!
                source.controller.add_mana(#{color}: #{count_expression})
              end
            end
          RUBY
        end

        private

        def count_expression
          KINDS.value?(counted) ? "source.controller.#{counted}.count" : "source.controller.creatures.by_type(#{counted.inspect}).count"
        end
      end
    end
  end
end
