module Magic
  module Costs
    # "As an additional cost to cast this spell, blight N or pay {M}." The payer
    # chooses one of the two: `pay(player:, payment:)` takes either a creature (to
    # blight) or a mana payment hash (to pay the extra mana instead). Unlike
    # `Costs::Blight` (built for activated abilities, whose costs are finalized
    # separately by `Player#activate_ability`), `Actions::Cast` never calls `finalize!`
    # on its additional costs -- they apply as soon as they're paid, like
    # `Costs::Sacrifice`/`Costs::Discard` do, so this does the same.
    class BlightOrMana
      attr_reader :source, :blight_amount, :mana_cost

      def initialize(source, blight_amount:, mana_cost:)
        @source = source
        @blight_amount = blight_amount
        @mana_cost = mana_cost
      end

      def can_pay?(player)
        Magic::Choice::Blight.possible?(player, source.game) || Costs::Mana.new(mana_cost).can_pay?(player)
      end

      def pay(player:, payment:)
        if payment.is_a?(Magic::Permanent)
          raise "#{payment.name} isn't a creature #{player.inspect} controls" unless payment.creature? && payment.controller == player

          payment.add_counter(Counters::Minus1Minus1, amount: blight_amount)
        else
          Costs::Mana.new(mana_cost).pay!(player:, payment:)
        end
      end

      def finalize!(_player)
      end
    end
  end
end
