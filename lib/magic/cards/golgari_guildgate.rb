module Magic
  module Cards
    class GolgariGuildgate < Card
      def initialize(**args)
        super(
          name: "Golgari Guildgate",
          **args
        )
      end

      def add_to_battlefield!
        self.tapped = true
        super
      end

      def tap!
        controller.game.add_effect(Effects::AddManaOrAbility.new(player: controller, black: 1, green: 1))
        super
      end
    end
  end
end
