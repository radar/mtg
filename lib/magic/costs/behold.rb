module Magic
  module Costs
    # "As an additional cost to cast this spell, behold a Kithkin [and exile it] [or pay {2}]."
    # To behold a Kithkin, choose a Kithkin you control or reveal a Kithkin card from your hand.
    # `pay(player:, payment:)` takes that permanent or card, or (with `or_mana`) a mana payment
    # hash to pay instead. With `exile`, the beheld object is exiled, and `resolved!` remembers
    # its card on the permanent the spell becomes (`Permanent#beheld_card`), which
    # `Behold::ReturnExiledCardTrigger` returns to its owner's hand when that permanent leaves.
    # Like `Costs::BlightOrMana`, `Actions::Cast` never calls `finalize!` on additional costs.
    class Behold
      attr_reader :source, :type, :exiled_card

      def initialize(source, type:, exile: false, or_mana: nil)
        @source = source
        @type = type
        @exile = exile
        @or_mana = or_mana
      end

      # The permanents you control and the cards in your hand that can be beheld.
      def candidates(player)
        permanents = player.permanents.select { _1.type?(type) }
        cards = player.hand.cards.select { _1.type?(type) && !_1.equal?(source) }
        [*permanents, *cards]
      end

      def can_pay?(player)
        candidates(player).any? || (!@or_mana.nil? && Costs::Mana.new(@or_mana).can_pay?(player))
      end

      def pay(player:, payment:)
        return pay_mana(player, payment) if payment.is_a?(Hash)

        raise "#{payment.name} can't be beheld for #{source.name}" unless candidates(player).include?(payment)

        payment.reveal! if payment.is_a?(Magic::Card)
        return unless @exile

        payment.exile!
        @exiled_card = payment.is_a?(Magic::Permanent) ? (payment.card unless payment.token?) : payment
      end

      def finalize!(_player)
      end

      # The spell resolved into `permanent`: it now holds the exiled card.
      def resolved!(permanent)
        permanent.beheld_card = exiled_card
      end

      private

      def pay_mana(player, payment)
        raise "#{source.name}'s behold cost can't be paid with mana" unless @or_mana

        Costs::Mana.new(@or_mana).pay!(player:, payment:)
      end
    end
  end
end
