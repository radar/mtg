module Magic
  class Choice
    class Ward < Magic::Choice
      attr_reader :payer, :spell, :ability, :generic

      def initialize(actor:, payer:, generic:, spell: nil, ability: nil)
        @payer = payer
        @spell = spell
        @ability = ability
        @generic = generic
        super(actor: actor)
      end

      def resolve!(payment: {})
        if payment.values.sum >= generic
          payer.pay_mana(payment)
        else
          item = stack_item
          game.stack.counter!(item) if item
        end
      end

      private

      # The spell or activated ability that targeted the warded permanent, if still on the stack.
      def stack_item
        if spell
          game.stack.spells.find { |item| item.card == spell }
        else
          game.stack.select { |item| item.respond_to?(:ability) && item.ability == ability }.first
        end
      end
    end
  end
end
