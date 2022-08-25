module Magic
  module Cards
    class ElderfangRitualist < Creature
      NAME = "Elderfang Ritualist"
      TYPE_LINE = "Creature -- Elf Cleric"
      POWER = 3
      TOUGHNESS = 1

      class Death < TriggeredAbility::Death
        def perform
          game.add_effect(
            Effects::SearchGraveyard.new(
              source: permanent,
              choices: controller.graveyard.by_any_type("Elf") - [permanent.card],
              resolve_action: -> (c) { c.move_to_hand!(controller) }
            )
          )
        end
      end

      def death_triggers = [Death]
    end
  end
end
