module Magic
  module Cards
    GuardianOfTheForgotten = Creature("Guardian of the Forgotten") do
      cost generic: 3, white: 1
      creature_type "Elephant Warrior"
      power 4
      toughness 4
      keywords :vigilance
    end

    class GuardianOfTheForgotten < Creature
      # "Whenever a modified creature you control dies, manifest the top card of your library."
      class ModifiedCreatureDiesTrigger < TriggeredAbility
        def should_perform?
          you? && event.permanent.modified?
        end

        def call
          top = controller.library.first
          game.manifest!(top, controller: controller) if top
        end
      end

      def event_handlers = super.merge({ Events::CreatureDied => ModifiedCreatureDiesTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
