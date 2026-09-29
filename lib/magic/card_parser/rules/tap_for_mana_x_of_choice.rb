# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "{T}: Add X {G} or X {W}, where X is the number of other creatures you control." A mana
      # ability whose colour is chosen and whose amount is counted when it resolves.
      class TapForManaXOfChoice < Data.define(:colors, :count)
        include Rule

        LINE = /\A\{T\}: Add X \{(?<first>[WUBRGC])\} or X \{(?<second>[WUBRGC])\}, where X is the number of (?<what>[^.]+)\.?\z/i

        def self.parse(line)
          return unless (m = LINE.match(line))

          count = Count.parse(m[:what]) or return
          colors = [m[:first], m[:second]].map { ManaCost::SYMBOL_TO_COLOR.fetch(_1.upcase) }
          new(colors:, count:)
        end

        def hook = :activated_abilities
        def class_base_name = "ManaAbility"

        def class_source(name)
          <<~RUBY
            class #{name} < Magic::TapManaAbility
              choices #{colors.map(&:inspect).join(', ')}

              def mana_produced = { choice => #{count} }
            end
          RUBY
        end
      end
    end
  end
end
