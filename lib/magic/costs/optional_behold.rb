module Magic
  module Costs
    # "As an additional cost to cast this spell, you may behold a Dragon." (Osseous Exhale), and
    # "You may cast this spell as though it had flash if you behold a Dragon as an additional cost to
    # cast it." (Molten Exhale, `grants_flash: true`). Optional, so it goes through the kicker plumbing
    # like `Costs::BeholdKicker`: the card's `kicker_cost` returns one, `Cast#pay_kicker(permanent_or_card)`
    # beholds (choose a `type` permanent you control, or reveal a `type` card from your hand), and the
    # spell's "if a Dragon was beheld" effects check `kicker_cost.paid?`. `Actions::Cast` calls `reset!`
    # once the spell has resolved or been countered, since `kicker_cost` lives as long as the card does.
    class OptionalBehold
      attr_reader :source, :type

      def initialize(source, type:, grants_flash: false)
        @source = source
        @type = type
        @grants_flash = grants_flash
        @paid = false
      end

      # The permanents you control and the cards in your hand that can be beheld.
      def candidates(player)
        permanents = player.permanents.select { _1.type?(type) }
        cards = player.hand.cards.select { _1.type?(type) && !_1.equal?(source) }
        [*permanents, *cards]
      end

      def can_pay?(player) = candidates(player).any?

      def pay(player:, payment:)
        raise "#{payment.name} can't be beheld for #{source.name}" unless candidates(player).include?(payment)

        payment.reveal! if payment.is_a?(Magic::Card)
        @paid = true
      end

      def paid? = @paid

      # Beholding lets the spell be cast "as though it had flash" (Molten Exhale).
      def grants_flash? = @grants_flash && @paid

      def reset! = @paid = false
    end
  end
end
