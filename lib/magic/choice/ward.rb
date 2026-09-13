module Magic
  class Choice
    class Ward < Magic::Choice
      attr_reader :payer, :spell, :generic

      def initialize(actor:, payer:, spell:, generic:)
        @payer = payer
        @spell = spell
        @generic = generic
        super(actor: actor)
      end

      def resolve!(payment: {})
        if payment.values.sum >= generic
          payer.pay_mana(payment)
        else
          spell_on_stack = game.stack.spells.find { |item| item.card == spell }
          game.stack.counter!(spell_on_stack) if spell_on_stack
        end
      end
    end
  end
end
