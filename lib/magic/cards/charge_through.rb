module Magic
  module Cards
    class ChargeThrough < Instant
      NAME = "Charge Through"
      COST = { green: 1 }

      def resolve!
        controller.draw!
        super
      end
    end
  end
end
