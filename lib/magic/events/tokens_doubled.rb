module Magic
  module Events
    # +source+ made an effect create twice as many tokens (Anointed Procession); +amount+ is the new number.
    class TokensDoubled < Base
      attr_reader :amount

      def initialize(source:, amount:)
        @amount = amount
        super(source: source)
      end

      def inspect
        "#<Events::TokensDoubled source: #{source&.name}, amount: #{amount}>"
      end
    end
  end
end
