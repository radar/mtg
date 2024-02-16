module Magic
  class Choice
    class Scry < Choice
      attr_reader :player, :amount

      def initialize(actor:, amount: 1)
        @actor = actor
        @amount = amount
        super(actor: actor)
      end

      def choices
        controller.library.first(amount)
      end

      def resolve!(top: [], bottom: [])
        controller.scry(amount:, top:, bottom:)
      end
    end
  end
end
