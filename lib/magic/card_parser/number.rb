# frozen_string_literal: true

module Magic
  class CardParser
    module Number
      WORDS = %w[zero one two three four five six seven eight nine ten].freeze

      # "3" => 3, "three" => 3, "a" => 1, and "X" => the Ruby expression for X while inside
      # `with_x` ("... where X is the number of colors among permanents you control").
      def self.parse(text)
        return @x if text == "X" && @x

        text = text.downcase
        return 1 if %w[a an].include?(text)
        return text.to_i if text.match?(/\A\d+\z/)

        WORDS.index(text) or raise UnsupportedCard, "unknown number: #{text}"
      end

      # Parses with "X" standing for the Ruby expression `expression`.
      def self.with_x(expression)
        previous = @x
        @x = expression
        yield
      ensure
        @x = previous
      end
    end
  end
end
