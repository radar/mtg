module Magic
  class Card
    class Protection
      attr_reader :condition, :until_eot

      def initialize(condition:, until_eot:)
        @condition = condition
        @until_eot = until_eot
      end

      def until_eot?
        @until_eot
      end

      def self.from_color(color, until_eot:)
        new(condition: -> (card) { card.colors.include?(color) }, until_eot: true)
      end

      def protected_from?(card)
        condition.call(card)
      end
    end
  end
end
