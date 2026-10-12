module Magic
  module Cards
    class GreatGildedBoat < Vehicle
      card_name "Great Gilded Boat"
      cost generic: 2, blue: 1
      power 4
      toughness 4
      crew 2

      # "Whenever you attack, recruit."
      class AttackTrigger < TriggeredAbility
        def should_perform? = event.active_player == controller && event.attacks.any?

        def call
          Magic::Recruit.call(player: controller)
        end
      end

      def event_handlers
        super.merge({ Events::FinalAttackersDeclared => AttackTrigger }) { |_, old, new| [*old, *new] }
      end
    end
  end
end
