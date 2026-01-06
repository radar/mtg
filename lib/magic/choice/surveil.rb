module Magic
  class Choice
    class Surveil < Choice
      attr_reader :player, :amount

      def initialize(actor:, amount: 1)
        @actor = actor
        @amount = amount
        super(actor: actor)
      end

      def choices
        controller.library.first(amount)
      end

      def resolve!(graveyard: [], top: [])
        controller.surveil(amount:, graveyard:, top:)
      end
    end
  end
end
