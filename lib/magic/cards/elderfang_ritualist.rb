module Magic
  module Cards
    ElderfangRitualist = Creature("ElderfangRitualist") do
      creature_type("Elf Cleric")
      cost generic: 2, white: 2
      power 3
      toughness 1
    end

    class ElderfangRitualist < Creature
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
