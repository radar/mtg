module Magic
  module Cards
    class GolgariGuildgate < Card
      def initialize(**args)
        zone = CardZone.new(
          battlefield_entry_effects: [
            -> { self.tapped = true },
          ]
        )

        super(
          name: "Golgari Guildgate",
          zone: zone,
          **args
        )
      end

      def tap!
        controller.game.add_effect(Effects::AddManaOrAbility.new(player: controller, black: 1, green: 1))
        super
      end
    end
  end
end
