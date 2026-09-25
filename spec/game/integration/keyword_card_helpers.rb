# frozen_string_literal: true

# Builds a throwaway creature from a few lines of card text, with just enough parsing for the
# keyword specs: "Name {cost}", "Type — Sub", keyword lines and "P/T". Replaces any card of the same
# name, so specs can define their own fixtures.
module KeywordCardHelpers
  COLORS = { "W" => "white", "U" => "blue", "B" => "black", "R" => "red", "G" => "green" }.freeze

  def creature(text, owner:)
    name, cost_text = text.lines.first.match(/\A(.+?) (\{.+\})\s*\z/).captures
    *rules, pt = text.lines.drop(2).map(&:strip)
    power, toughness = pt.split("/")
    const = name.delete(" ")

    Magic::Cards.send(:remove_const, const) if Magic::Cards.const_defined?(const, false)
    Magic::Cards.module_eval(<<~RUBY, __FILE__, __LINE__ + 1)
      #{const} = Creature(#{name.inspect}) do
        cost #{cost_arguments(cost_text)}
        creature_type #{text.lines[1][/— (.+)/, 1].strip.inspect}
        power #{power}
        toughness #{toughness}
        #{rules.filter_map { dsl_line(_1) }.join("\n  ")}
      end

      #{hexproof_from_reopening(const, rules)}
    RUBY
    ResolvePermanent(name, owner: owner)
  end

  private

  def cost_arguments(cost_text)
    symbols = cost_text.scan(/\{(\w+)\}/).flatten
    generic = symbols.grep(/\A\d+\z/).sum(&:to_i)
    colored = symbols.grep(/\A[WUBRG]\z/).tally.map { |symbol, count| "#{COLORS[symbol]}: #{count}" }
    [("generic: #{generic}" if generic.positive?), *colored].compact.join(", ")
  end

  # "Hexproof from red" is a keyword object, which only a class reopening can give a card
  # (see SporewebWeaver).
  def hexproof_from_reopening(const, rules)
    colors = rules.filter_map { _1[/\AHexproof from (\w+)\z/, 1] }
    return "" if colors.empty?

    keywords = colors.map { "Keywords::HexproofFrom.new(:#{_1})" }.join(", ")
    "class #{const} < Creature\n  KEYWORDS = [#{keywords}]\nend"
  end

  def dsl_line(rule)
    case rule
    when /\AHexproof from / then nil
    when /\AProtection from (\w+)\z/ then "protections [Magic::Protection.from_color(:#{$1})]"
    when /\AWard \{(\d+)\}\z/ then "ward generic: #{$1}"
    else "keywords :#{rule.downcase.tr(' ', '_')}"
    end
  end
end
