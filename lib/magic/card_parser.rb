# frozen_string_literal: true

module Magic
  # Parses the plain-text card format (name + mana cost, type line, rules lines,
  # P/T) into a Result. Header, type line and P/T are handled here; each rules
  # line is handed to the first class in CardParser::Rule.all that recognises it
  # (see lib/magic/card_parser/rules/). A line no rule recognises raises
  # UnsupportedCard.
  #
  #   Aegis Turtle {U}
  #   Creature — Turtle
  #
  #   0/5
  class CardParser
    class ParseError < StandardError; end
    class UnsupportedCard < ParseError; end

    Result = Struct.new(:name, :mana_cost, :supertypes, :types, :subtypes, :rules, :power, :toughness, keyword_init: true) do
      def creature?
        types.include?("Creature")
      end

      def legendary?
        supertypes.include?("Legendary")
      end

      def keywords
        rules.grep(Rules::Keywords).flat_map(&:keywords)
      end

      # Every rule that isn't a keyword line.
      def abilities
        rules.reject { |rule| rule.is_a?(Rules::Keywords) }
      end
    end

    SUPERTYPES = %w[Legendary Basic Snow World].freeze
    NAME_AND_COST = /\A(?<name>.+?)(?:\s+(?<cost>(?:\{[^}]+\})+))?\z/
    PT = %r{\A(?<power>-?\d+)/(?<toughness>-?\d+)\z}

    def self.parse(text)
      new(text).parse
    end

    def initialize(text)
      @lines = text.strip.lines.map { |line| line.gsub(/\s*\([^)]*\)/, "").strip }.reject(&:empty?)
    end

    def parse
      raise ParseError, "expected name, type line and power/toughness" if @lines.size < 2

      header, type_line, *rest = @lines
      pt_line = rest.pop if rest.last&.match?(PT)
      rules = parse_rules(rest)

      header_match = NAME_AND_COST.match(header) or raise ParseError, "bad name line: #{header}"
      supertypes, types, subtypes = parse_type_line(type_line)
      pt = PT.match(pt_line) if pt_line
      raise ParseError, "creature needs power/toughness" if types.include?("Creature") && pt.nil?

      Result.new(
        name: header_match[:name],
        mana_cost: ManaCost.parse(header_match[:cost]),
        supertypes:, types:, subtypes:, rules:,
        power: pt && pt[:power].to_i,
        toughness: pt && pt[:toughness].to_i
      )
    end

    private

    def parse_type_line(line)
      left, right = line.split(/\s+[—-]\s+/, 2)
      words = left.split
      supertypes = words & SUPERTYPES
      [supertypes, words - supertypes, right.to_s.split]
    end

    def parse_rules(lines)
      parsed = lines.map do |line|
        Rule.all.lazy.filter_map { |rule| rule.parse(line) }.first or
          raise UnsupportedCard, "rules text not supported: #{line}"
      end
      parsed.group_by(&:class).flat_map { |klass, rules| klass.merge(rules) }
    end
  end
end
