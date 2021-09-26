module Magic
  module Cards
    class ChargeThrough < Instant
      def initialize(**args)
        zone = CardZone.new(
          battlefield_entry_effects: [
            -> { controller.draw! },
          ]
        )

        super(
          name: "Charge Through",
          cost: { green: 1 },
          zone: zone,
          **args
        )
      end

      private
    end
  end
end
