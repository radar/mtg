module Magic
  module Cards
    class ElderfangRitualist < Creature
      NAME = "Elderfang Ritualist"
      TYPE_LINE = "Creature -- Elf Cleric"
      POWER = 3
      TOUGHNESS = 1

      def died!
        game.add_effect(
          Effects::SearchGraveyard.new(
            source: self,
            choices: controller.graveyard.by_any_type("Elf"),
            resolve_action: -> (c) { c.move_to_hand!(controller) }
          )
        )
      end
    end
  end
end
