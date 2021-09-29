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
            graveyard: controller.graveyard,
            condition: -> (c) { c.creature? && c.type?("Elf") },
            resolve_action: -> (c) { c.move_to_hand!(controller) }
          )
        )
      end
    end
  end
end
