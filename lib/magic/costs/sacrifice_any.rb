module Magic
  module Costs
    # "As an additional cost to cast this spell, you may sacrifice any number of nonland permanents. This spell
    # costs {1} less to cast for each permanent sacrificed this way." (Rottenmouth Viper.) Optional, so
    # `Actions::Cast#perform` pays it with nothing sacrificed unless `Actions::Cast#pay_sacrifice_any` already did.
    class SacrificeAny
      attr_reader :source, :sacrificed

      def initialize(source)
        @source = source
        @sacrificed = []
      end

      def choices(player) = player.permanents.reject(&:land?)

      def pay(player:, payment:)
        payment = Array(payment).uniq
        raise "can only sacrifice nonland permanents you control" unless (payment - choices(player)).empty?

        payment.each(&:sacrifice!)
        @sacrificed = payment
      end

      def auto_pay!(_player)
      end

      def finalize!(_player)
      end
    end
  end
end
