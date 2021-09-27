module Magic
  module Cards
    class HillGiantHerdgorger < Creature
      def initialize(**args)
        zone = CardZone.new(
          battlefield_entry_effects: [
            -> { controller.gain_life(3) },
          ]
        )

        super(
          name: "Hill Giant Herdgorger",
          cost: { green: 2, any: 4 },
          zone: zone,
          **args
        )
      end
    end
  end
end
