module Magic
  class Choice
    class Scry < Choice
      attr_reader :player, :amount

      def initialize(source:, amount: 1)
        @source = source
        @amount = amount
        super(source: source)
      end

      def choices
        controller.library.first(amount)
      end

      def resolve!(top: [], bottom: [])
        source.controller.scry(amount:, top:, bottom:)
      end
    end
  end
end
