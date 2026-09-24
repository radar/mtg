# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "{T}: Add {W} or {U}." / "{T}: Add {R}, {G}, or {W}." / "{T}: Add one mana
      # of any color." / "...of any color in your commander's color identity."
      # The player picks the colour when activating.
      class TapForManaChoice < Data.define(:colors)
        include Rule

        SYMBOL = /\{[WUBRGC]\}/
        LINE = /\A\{T\}: Add (?<symbols>#{SYMBOL}(?:, #{SYMBOL})*,? or #{SYMBOL})\.?\z/
        ANY_COLOR = /\A\{T\}: Add one mana of any color\.?\z/
        COMMANDER_COLORS = /\A\{T\}: Add one mana of any color in your commander's color identity\.?\z/

        def self.parse(line)
          return new(colors: [:all]) if ANY_COLOR.match?(line)
          return new(colors: [:commander]) if COMMANDER_COLORS.match?(line)
          return unless (m = LINE.match(line))

          new(colors: m[:symbols].scan(SYMBOL).flat_map { ManaCost.parse(_1).keys })
        end

        def hook = :activated_abilities
        def class_base_name = "ManaAbility"

        def class_source(name)
          # Any colour in the controller's commander's colour identity.
          choices = colors == [:commander] ? "def choices = controller.commander.color_identity" : "choices #{colors.map(&:inspect).join(', ')}"
          <<~RUBY
            class #{name} < Magic::TapManaAbility
              #{choices}
            end
          RUBY
        end
      end
    end
  end
end
