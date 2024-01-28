module Magic
  class Choice
    class Scry < Choice
      attr_reader :player, :amount

      def initialize(source:, amount:)
        @source = source
        @amount = amount
        super(source: source)
      end

      def requires_choices?
        true
      end

      def resolve!(top: [], bottom: [])
        source.controller.scry(amount:, top:, bottom:)
      end
    end
  end
end
