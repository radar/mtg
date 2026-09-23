# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # Saga chapter abilities: "I — Create a 1/1 white Human Warrior creature token."
      # or "II, III — Draw a card." A card's chapter lines merge into one rule that
      # generates a Saga::ChapterAbility per chapter plus `def chapters`. Each
      # chapter's effects render like a triggered ability's (EffectList#trigger_source).
      class Chapter < Data.define(:chapters)
        include Rule

        NUMERALS = %w[I II III IV V VI].freeze
        LINE = /\A(?<numerals>[IVX]+(?:,\s*[IVX]+)*)\s+[—-]\s+(?<text>.+)\z/

        def self.parse(line)
          return unless (m = LINE.match(line))

          numbers = m[:numerals].split(/,\s*/).map { |numeral| NUMERALS.index(numeral) or raise UnsupportedCard, "unknown chapter: #{numeral}" }
          effect_list = EffectList.parse(m[:text]) or raise UnsupportedCard, "chapter effect not supported: #{m[:text]}"
          new(chapters: numbers.to_h { [_1 + 1, effect_list] })
        end

        def self.merge(rules)
          chapters = rules.flat_map { _1.chapters.to_a }
          numbers = chapters.map(&:first)
          raise ParseError, "chapters must run I, II, III... without gaps: #{numbers.inspect}" if numbers != (1..numbers.size).to_a

          [new(chapters: chapters.to_h)]
        end

        def kinds = %i[saga]

        def body_source
          classes = chapters.map { |number, effect| chapter_source(number, effect) }
          [*classes, "def chapters\n  [#{chapters.keys.map { "Chapter#{_1}" }.join(', ')}]\nend\n"].join("\n")
        end

        private

        def chapter_source(number, effect_list)
          body = effect_list.trigger_source(entry: "resolve!").gsub(/^(?=.)/, "  ")
          "class Chapter#{number} < Saga::ChapterAbility\n#{body}end\n"
        end
      end
    end
  end
end
