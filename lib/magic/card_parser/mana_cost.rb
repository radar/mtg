# frozen_string_literal: true

module Magic
  class CardParser
    module ManaCost
      SYMBOL_TO_COLOR = { "W" => :white, "U" => :blue, "B" => :black, "R" => :red, "G" => :green, "C" => :colorless }.freeze

      # "{2}{U}" => { generic: 2, blue: 1 }
      def self.parse(cost)
        return {} if cost.nil?

        cost.scan(/\{([^}]+)\}/).flatten.each_with_object(Hash.new(0)) do |symbol, result|
          if symbol.match?(/\A\d+\z/)
            result[:generic] += symbol.to_i
          elsif (color = SYMBOL_TO_COLOR[symbol])
            result[color] += 1
          else
            raise UnsupportedCard, "unsupported mana symbol {#{symbol}}"
          end
        end.to_h
      end
    end
  end
end
