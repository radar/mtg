module Magic
  class Choice
    # "Counter it unless that player pays the ward cost": mana (`generic`), life (`life`, "Ward--Pay 2 life"),
    # a discard ("Ward--Discard a card"), a sacrifice ("Ward--Sacrifice a Food", "Ward--Sacrifice three nonland
    # permanents"), or several ("Ward--{3}, Pay 3 life"). Answer with `payment:` (mana), `pay_life: true`,
    # `discard: card`, `sacrifice: permanent` and/or `sacrifices: [permanents]`; anything short of the full cost
    # counters the spell or ability.
    class Ward < Magic::Choice
      attr_reader :payer, :spell, :ability, :generic, :life, :sacrifice_type, :sacrifice_nonland, :sacrifice_any

      # `discard: true` is "Ward--Discard a card"; `sacrifice: "Food"` is "Ward--Sacrifice a Food";
      # `sacrifice_nonland: 3` is "Ward--Sacrifice three nonland permanents"; `sacrifice_any: 2` is
      # "Ward--Sacrifice two permanents".
      def initialize(actor:, payer:, generic: nil, life: nil, discard: false, sacrifice: nil, sacrifice_nonland: nil, sacrifice_any: nil, spell: nil, ability: nil)
        @sacrifice_any = sacrifice_any
        @payer = payer
        @spell = spell
        @ability = ability
        @generic = generic
        @life = life
        @discard = discard
        @sacrifice_type = sacrifice
        @sacrifice_nonland = sacrifice_nonland
        super(actor: actor)
      end

      def discard? = @discard

      def resolve!(payment: {}, pay_life: false, discard: nil, sacrifice: nil, sacrifices: [])
        if paid?(payment, pay_life, discard, sacrifice, sacrifices)
          payer.pay_mana(payment) if generic
          lose_life payer, life if life
          payer.hand.discard(discard) if discard?
          sacrifice.sacrifice! if sacrifice_type
          sacrifices.each(&:sacrifice!) if sacrifice_nonland || sacrifice_any
        else
          item = stack_item
          game.stack.counter!(item) if item
        end
      end

      private

      # A player can't pay more life than they have. A ward cost with several parts needs all of them.
      def paid?(payment, pay_life, discard, sacrifice, sacrifices)
        return false if life && !(pay_life && payer.life >= life)
        return false if generic && payment.values.sum < generic
        return false if discard? && !(discard && payer.hand.cards.include?(discard))
        return false if sacrifice_type && !(sacrifice&.type?(sacrifice_type) && sacrifice.controller == payer)
        return false if sacrifice_nonland && !sacrifice_payable?(sacrifices)
        return false if sacrifice_any && !any_sacrifice_payable?(sacrifices)

        true
      end

      def any_sacrifice_payable?(sacrifices)
        sacrifices.size == sacrifice_any && sacrifices.uniq.size == sacrifice_any &&
          sacrifices.all? { |permanent| permanent.controller == payer }
      end

      def sacrifice_payable?(sacrifices)
        sacrifices.size == sacrifice_nonland && sacrifices.uniq.size == sacrifice_nonland &&
          sacrifices.all? { |permanent| permanent.controller == payer && !permanent.land? }
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
