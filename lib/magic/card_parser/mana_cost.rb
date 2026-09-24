# frozen_string_literal: true

module Magic
  class CardParser
    module ManaCost
      SYMBOL_TO_COLOR = { "W" => :white, "U" => :blue, "B" => :black, "R" => :red, "G" => :green, "C" => :colorless }.freeze
      HYBRID = %r{\A([WUBRG])/([WUBRG])\z}

      # "{2}{U}" => { generic: 2, blue: 1 }
      # "{B/G}{B/G}" => { black_or_green: 2 } (the colours sorted, as Costs::Parsers::Mana keys them)
      # "{X}{R}" => { x: 1, red: 1 }
      def self.parse(cost)
        return {} if cost.nil?

        cost.scan(/\{([^}]+)\}/).flatten.each_with_object(Hash.new(0)) do |symbol, result|
          if symbol.match?(/\A\d+\z/)
            result[:generic] += symbol.to_i
          elsif (color = SYMBOL_TO_COLOR[symbol])
            result[color] += 1
          elsif (hybrid = HYBRID.match(symbol))
            result[:"#{hybrid.captures.map { SYMBOL_TO_COLOR.fetch(_1) }.sort.join('_or_')}"] += 1
          elsif symbol == "X"
            result[:x] += 1
          else
            raise UnsupportedCard, "unsupported mana symbol {#{symbol}}"
          end
        end.to_h
      end
    end
  end
end
