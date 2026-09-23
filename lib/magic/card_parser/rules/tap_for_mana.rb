# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "{T}: Add {G}{G}{G}."
      class TapForMana < Data.define(:mana)
        include Rule

        LINE = /\A\{T\}: Add (?<mana>(?:\{[WUBRGC]\})+)\.?\z/

        def self.parse(line)
          return unless (m = LINE.match(line))

          new(mana: ManaCost.parse(m[:mana]))
        end

        def hook = :activated_abilities
        def class_base_name = "ManaAbility"

        def class_source(name)
          args = mana.map { |color, amount| "#{color}: #{amount}" }.join(", ")
          <<~RUBY
            class #{name} < Magic::TapManaAbility
              def resolve!
                source.controller.add_mana(#{args})
              end
            end
          RUBY
        end
      end
    end
  end
end
