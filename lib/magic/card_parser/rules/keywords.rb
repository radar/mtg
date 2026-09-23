# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "Flying, first strike" => keywords :flying, :first_strike
      class Keywords < Data.define(:keywords)
        include Rule

        KNOWN = %w[deathtouch defender double_strike first_strike flash flying haste hexproof indestructible
                   infect lifelink menace prowess reach shroud skulk trample vigilance].freeze

        def self.parse(line)
          words = line.split(",").map { |word| word.strip.downcase.tr(" ", "_") }
          new(keywords: words.map(&:to_sym)) if words.all? { |word| KNOWN.include?(word) }
        end

        def self.merge(rules)
          rules.empty? ? [] : [new(keywords: rules.flat_map(&:keywords))]
        end

        def dsl_lines = ["keywords #{keywords.map(&:inspect).join(', ')}"]
      end
    end
  end
end
