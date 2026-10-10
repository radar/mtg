module Magic
  class Choice
    # "Counter it unless that player pays the ward cost": mana (`generic`) or life (`life`,
    # "Ward--Pay 2 life"), or both ("Ward--{3}, Pay 3 life"). Answer with `payment:` (mana) and/or
    # `pay_life: true`; anything short of the full cost counters the spell or ability.
    class Ward < Magic::Choice
      attr_reader :payer, :spell, :ability, :generic, :life, :discard

      # `discard: true` is "Ward--Discard a card"; answer with `discard: card` (a card in the payer's hand).
      def initialize(actor:, payer:, generic: nil, life: nil, discard: false, spell: nil, ability: nil)
        @payer = payer
        @spell = spell
        @ability = ability
        @generic = generic
        @life = life
        @discard = discard
        super(actor: actor)
      end

      def resolve!(payment: {}, pay_life: false, discard: nil)
        if paid?(payment, pay_life, discard)
          payer.pay_mana(payment) if generic
          trigger_effect(:lose_life, target: payer, life: life) if life
          payer.hand.discard(discard) if self.discard
        else
          item = stack_item
          game.stack.counter!(item) if item
        end
      end

      private

      # A player can't pay more life than they have. A ward cost with both ("Ward--{3}, Pay 3 life")
      # needs both paid.
      def paid?(payment, pay_life, discard)
        return false if self.discard && !payer.hand.include?(discard)
        return false if life && !(pay_life && payer.life >= life)
        return false if generic && payment.values.sum < generic

        true
      end

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
