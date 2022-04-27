module Magic
  class Card
    class Protection
      attr_reader :condition, :until_eot

      def initialize(condition:, until_eot: false, protects_player: false)
        @condition = condition
        @until_eot = until_eot
        @protects_player = protects_player
      end

      def protects_player?
        @protects_player
      end

      def until_eot?
        @until_eot
      end

      def self.from_color(color, until_eot: false)
        new(condition: -> (card) { card.colors.include?(color) }, until_eot: until_eot)
      end

      def protected_from?(card)
        condition.call(card)
      end
    end
  end
end
