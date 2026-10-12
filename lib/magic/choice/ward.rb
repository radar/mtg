module Magic
  class Choice
    # "Counter it unless that player pays the ward cost": mana (`generic`), life (`life`, "Ward--Pay 2 life"),
    # a discard ("Ward--Discard a card") or a sacrifice ("Ward--Sacrifice a Food"), or several ("Ward--{3},
    # Pay 3 life"). Answer with `payment:` (mana), `pay_life: true`, `discard: card` and/or `sacrifice:
    # permanent`; anything short of the full cost counters the spell or ability.
    class Ward < Magic::Choice
      attr_reader :payer, :spell, :ability, :generic, :life, :sacrifice_type

      def initialize(actor:, payer:, generic: nil, life: nil, discard: false, sacrifice: nil, spell: nil, ability: nil)
        @payer = payer
        @spell = spell
        @ability = ability
        @generic = generic
        @life = life
        @discard = discard
        @sacrifice_type = sacrifice
        super(actor: actor)
      end

      def discard? = @discard

      def resolve!(payment: {}, pay_life: false, discard: nil, sacrifice: nil)
        if paid?(payment, pay_life, discard, sacrifice)
          payer.pay_mana(payment) if generic
          trigger_effect(:lose_life, target: payer, life: life) if life
          discard.discard! if discard?
          sacrifice.sacrifice! if sacrifice_type
        else
          item = stack_item
          game.stack.counter!(item) if item
        end
      end

      private

      # A player can't pay more life than they have. A ward cost with several parts needs all of them.
      def paid?(payment, pay_life, discard, sacrifice)
        return false if life && !(pay_life && payer.life >= life)
        return false if generic && payment.values.sum < generic
        return false if discard? && !(discard && payer.hand.cards.include?(discard))
        return false if sacrifice_type && !(sacrifice&.type?(sacrifice_type) && sacrifice.controller == payer)

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
