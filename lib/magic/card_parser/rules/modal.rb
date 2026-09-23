# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # A modal instant or sorcery: a "Choose one —" line and a "• <effects>" line
      # per mode, merged into one rule that generates a Mode class per bullet and
      # `modes Mode1, Mode2, ...`. The caster picks modes with `choose_mode`; how
      # many they may pick ("one or both") isn't enforced.
      class Modal < Data.define(:choose, :modes)
        include Rule

        HEADER = /\AChoose (?<choose>one|one or both|one or more|two) [—-]\z/
        BULLET = /\A• (?<text>.+)\z/

        def self.parse(line)
          if (m = HEADER.match(line))
            new(choose: m[:choose], modes: [])
          elsif (m = BULLET.match(line)) && (effect_list = EffectList.parse(m[:text]))
            new(choose: nil, modes: [effect_list])
          end
        end

        def self.merge(rules)
          headers = rules.filter_map(&:choose)
          raise ParseError, "modal spell needs one \"Choose ... —\" line" unless headers.one?

          modes = rules.flat_map(&:modes)
          raise ParseError, "modal spell needs at least two • modes" if modes.size < 2

          [new(choose: headers.first, modes:)]
        end

        def kinds = %i[instant sorcery]

        def body_source
          classes = modes.each_with_index.map do |effect_list, index|
            body = effect_list.spell_source(this: "card").gsub(/^(?=.)/, "  ")
            "class Mode#{index + 1} < Mode\n#{body}end\n"
          end
          [*classes, "modes #{(1..modes.size).map { "Mode#{_1}" }.join(', ')}\n"].join("\n")
        end
      end
    end
  end
end
