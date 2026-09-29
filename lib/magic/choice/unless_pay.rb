module Magic
  class Choice
    # "Sacrifice ~ unless you pay {W}{W}." / "Tap ~ unless you pay 2 life." / "... unless you
    # discard a card." / "... unless you sacrifice a creature." Answer with `payment:` (mana as in
    # `Costs::Mana#pay`, else the mana is paid automatically; or the card/permanent to discard or
    # sacrifice); declining, or being unable to pay, applies the penalty to the actor.
    class UnlessPay < Magic::Choice::May
      PENALTIES = %i[sacrifice tap].freeze

      attr_reader :penalty, :mana, :life, :discard, :sacrifice_type

      def initialize(actor:, penalty:, mana: nil, life: nil, discard: false, sacrifice_type: nil)
        raise ArgumentError, "unknown penalty #{penalty.inspect}" unless PENALTIES.include?(penalty)

        @penalty = penalty
        @mana = mana
        @life = life
        @discard = discard
        @sacrifice_type = sacrifice_type
        super(actor: actor)
      end

      # What can be discarded or sacrificed to avoid the penalty.
      def choices
        return hand.cards.to_a if discard
        return controller.permanents.select { _1.type?(sacrifice_type) } if sacrifice_type

        []
      end

      def resolve!(payment: nil)
        paid = if mana then pay_mana(payment)
               elsif life then pay_life
               elsif discard || sacrifice_type then pay_card(payment)
               end
        unpaid! unless paid
      end

      def decline! = unpaid!

      private

      def pay_mana(payment)
        cost = Costs::Mana.new(mana)
        return false unless cost.can_pay?(controller)

        if payment
          cost.pay!(player: controller, payment: payment)
        else
          cost.auto_pay(player: controller)
          cost.finalize!(controller)
        end
        true
      end

      # A player can't pay more life than they have.
      def pay_life
        return false if controller.life < life

        trigger_effect(:lose_life, target: controller, life: life)
        true
      end

      def pay_card(card)
        return false unless choices.include?(card)

        discard ? card.move_to_graveyard! : card.sacrifice!
        true
      end

      def unpaid!
        penalty == :sacrifice ? trigger_effect(:sacrifice, target: actor) : actor.tap!
      end
    end
  end
end
