module Magic
  class TriggeredAbility
    # "Eerie -- Whenever an enchantment you control enters and whenever you fully unlock a Room, ...". Subclass it,
    # define `call`, and list `EerieTrigger.handlers` in the card's `event_handlers`:
    #
    #   class EerieTrigger < TriggeredAbility::Eerie
    #     def call = trigger_effect(:draw_card)
    #   end
    #
    #   def event_handlers = EerieTrigger.handlers
    #
    # A Room is an enchantment, so casting one fires it twice over its life: once as it enters and once when its second
    # door is unlocked.
    class Eerie < TriggeredAbility
      def self.handlers
        { Events::EnteredTheBattlefield => self, Events::RoomFullyUnlocked => self }
      end

      def should_perform?
        case event
        when Events::EnteredTheBattlefield then event.permanent.enchantment? && event.permanent.controller == controller
        when Events::RoomFullyUnlocked then event.player == controller
        end
      end
    end
  end
end
