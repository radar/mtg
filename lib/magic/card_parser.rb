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

    Result = Struct.new(:name, :mana_cost, :supertypes, :types, :subtypes, :rules, :power, :toughness, :loyalty, :color_indicator, :back_face, keyword_init: true) do
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
    # Current card text says "this creature" where older text used the card's name.
    THIS_OBJECT = /\b[Tt]his (?:creature|artifact|enchantment|land|permanent|Equipment|Aura|Saga|spell|card)\b/
    PT = %r{\A(?<power>-?\d+|\*)/(?<toughness>-?\d+)\z}
    LOYALTY = /\ALoyalty: (?<loyalty>\d+)\z/i

    # Every class in lib/magic/card_parser/<dir>/, so a new file needs no registration.
    def self.load_all(dir, namespace)
      Dir[File.join(__dir__, "card_parser", dir, "*.rb")].sort.map do |path|
        namespace.const_get(File.basename(path, ".rb").split("_").map(&:capitalize).join)
      end
    end

    FACE_SEPARATOR = /^----\s*$/
    COLOR_INDICATOR = /\AColor Indicator: (?<colors>.+)\z/i

    # A double-faced card is its two faces' texts joined by a "----" line: the front face, then the
    # back (whose header has no mana cost and may be followed by a "Color Indicator: Black" line).
    def self.parse(text)
      front, back = text.split(FACE_SEPARATOR, 2)
      return new(text).parse unless back

      short_names = [front, back].filter_map { |face| first_name_of(face) }
      new(front, short_names:).parse.tap { |result| result.back_face = new(back, short_names:).parse }
    end

    # "Trystan" from "Trystan, Callous Cultivator".
    def self.first_name_of(face_text)
      name = face_text.strip.lines.first.to_s[/\A[^{\n]+/].to_s.strip
      name.split(",").first if name.include?(",")
    end

    def initialize(text, short_names: [])
      @name = text.strip.lines.first.to_s[/\A[^{\n]+/].to_s.strip
      # A double-faced card's rules text may call either face by its first name ("transform Eirdu").
      @short_names = short_names
      @lines = text.strip.lines.map { |line| line.gsub(/\s*\([^)]*\)/, "").strip }.reject(&:empty?)
    end

    def parse
      raise ParseError, "expected name, type line and power/toughness" if @lines.size < 2

      header, *rest = @lines
      color_indicator = parse_color_indicator(rest.shift) if rest.first&.match?(COLOR_INDICATOR)
      type_line, *rest = rest
      pt_line = rest.pop if rest.last&.match?(PT)
      loyalty = LOYALTY.match(rest.pop)[:loyalty].to_i if rest.last&.match?(LOYALTY)
      rules = parse_rules(rest.map { |line| own_name_to_tilde(line) })

      header_match = NAME_AND_COST.match(header) or raise ParseError, "bad name line: #{header}"
      supertypes, types, subtypes = parse_type_line(type_line)
      pt = PT.match(pt_line) if pt_line
      raise ParseError, "creature needs power/toughness" if types.include?("Creature") && pt.nil?
      raise UnsupportedCard, "a * power needs a rule defining it" if pt && pt[:power] == "*" && rules.none?(Rules::CharacteristicPower)
      raise ParseError, "planeswalker needs a \"Loyalty: N\" line" if types.include?("Planeswalker") && loyalty.nil?

      Result.new(
        name: header_match[:name],
        mana_cost: ManaCost.parse(header_match[:cost]),
        supertypes:, types:, subtypes:, rules:,
        power: pt && pt[:power].to_i, # "*" is 0 here; Rules::CharacteristicPower supplies the value
        toughness: pt && pt[:toughness].to_i,
        loyalty:,
        color_indicator:
      )
    end

    private

    def own_name_to_tilde(line)
      line = line.gsub(@name, "~")
      @short_names.each { |short| line = line.gsub(/\b#{Regexp.escape(short)}\b/, "~") }
      line.gsub(THIS_OBJECT, "~")
    end

    # "Color Indicator: Black" / "Blue and Red" -> [:black] / [:blue, :red]
    def parse_color_indicator(line)
      names = COLOR_INDICATOR.match(line)[:colors].downcase.split(/,\s*|\s+and\s+/)
      names.map do |name|
        color = %w[white blue black red green].find { _1 == name } or raise UnsupportedCard, "unknown colour: #{name}"
        color.to_sym
      end
    end

    def parse_type_line(line)
      left, right = line.split(/\s+[—-]\s+/, 2)
      words = left.split
      supertypes = words & SUPERTYPES
      [supertypes, words - supertypes, right.to_s.split]
    end

    # An italic ability word ("Vivid — ", "Landfall — ") is flavour.
    ABILITY_WORD = /\A[A-Z][a-z]+(?: [a-z]+)* — /

    def parse_rules(lines)
      parsed = lines.map { _1.sub(ABILITY_WORD, "") }.map do |line|
        Rule.all.lazy.filter_map { |rule| rule.parse(line) }.first or
          raise UnsupportedCard, "rules text not supported: #{line}"
      end
      parsed.group_by(&:class).flat_map { |klass, rules| klass.merge(rules) }
    end
  end
end
