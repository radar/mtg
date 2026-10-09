module Magic
  module Costs
    # "As an additional cost to cast this spell, sacrifice a <type> or pay {M}." Paid with
    # `action.pay_additional_cost(Costs::SacrificeOrMana, payment)`, where `payment` is the permanent to sacrifice or a
    # mana payment hash for the "or pay" alternative. Like the other additional costs, it applies as soon as it is paid.
    class SacrificeOrMana
      attr_reader :source, :mana_cost

      # `types` are the type names that may be sacrificed (any one of them).
      def initialize(source, types:, mana_cost:)
        @source = source
        @types = types
        @mana_cost = mana_cost
      end

      def choices(player)
        player.permanents.select { |permanent| @types.any? { permanent.type?(_1) } }
      end

      def can_pay?(player)
        choices(player).any? || Costs::Mana.new(mana_cost).can_pay?(player)
      end

      def pay(player:, payment:)
        if payment.is_a?(Magic::Permanent)
          raise "#{payment.name} can't be sacrificed for #{source.name}" unless choices(player).include?(payment)

          payment.sacrifice!
        else
          Costs::Mana.new(mana_cost).pay!(player:, payment:)
        end
      end

      def finalize!(_player)
      end
    end
  end
end
