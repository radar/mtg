module Magic
  module Costs
    # "As an additional cost to cast this spell, you may choose a creature type and behold two
    # creatures of that type." Optional, so it goes through the kicker plumbing
    # (`Cast#pay_kicker`, `card.kicker_cost.paid?`) like `Costs::BlightKicker`. The payment is
    # `{ creature_type: "Elf", objects: [permanent_or_card, permanent_or_card] }`: two different
    # permanents you control or cards in your hand of that type. The card calls `reset!` once it has
    # read the result, since `kicker_cost` lives as long as the card does.
    class BeholdKicker
      attr_reader :creature_type

      def initialize(source, count: 2)
        @source = source
        @count = count
        @paid = false
      end

      def pay(player:, payment:)
        type = payment.fetch(:creature_type)
        objects = payment.fetch(:objects)
        candidates = candidates(player, type)
        raise "Behold #{@count} #{type} creatures: got #{objects.size}" unless objects.size == @count && objects.uniq.size == @count
        raise "#{objects.map(&:name).join(', ')} can't all be beheld as #{type}" unless objects.all? { candidates.include?(_1) }

        objects.each { _1.reveal! if _1.is_a?(Magic::Card) }
        @creature_type = type
        @paid = true
      end

      def paid? = @paid

      def reset!
        @paid = false
        @creature_type = nil
      end

      private

      def candidates(player, type)
        [*player.permanents.select { _1.creature? && _1.type?(type) },
         *player.hand.cards.select { _1.creature? && _1.type?(type) && !_1.equal?(@source) }]
      end
    end
  end
end
