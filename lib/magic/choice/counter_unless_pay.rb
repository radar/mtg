module Magic
  class Choice
    # "Counter target spell unless its controller pays {2}." The spell's controller (`payer`) decides:
    # accepting (`game.resolve_choice!`, optionally `payment:` as for `Costs::Mana#pay!`, else paid
    # automatically) pays the mana; declining, or being unable to pay, counters the spell.
    class CounterUnlessPay < Magic::Choice::May
      attr_reader :spell, :payer, :mana

      def initialize(actor:, spell:, mana:)
        @spell = spell
        @payer = spell.player
        @mana = mana
        super(actor: actor)
      end

      def controller = @payer

      def can_pay? = Costs::Mana.new(mana).can_pay?(payer)

      def resolve!(payment: nil)
        return decline! unless can_pay?

        cost = Costs::Mana.new(mana)
        if payment
          cost.pay!(player: payer, payment: payment)
        else
          cost.auto_pay(player: payer)
          cost.finalize!(payer)
        end
      end

      def decline!
        trigger_effect(:counter_spell, target: spell)
      end
    end
  end
end
