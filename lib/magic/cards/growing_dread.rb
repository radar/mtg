module Magic
  module Cards
    GrowingDread = Enchantment("Growing Dread") do
      cost green: 1, blue: 1
      keywords :flash
    end

    class GrowingDread < Enchantment
      # "When this enchantment enters, manifest dread."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          Magic::Choice::ManifestDread.perform(actor: actor)
        end
      end

      # "Whenever you turn a permanent face up, put a +1/+1 counter on it."
      class TurnedFaceUpTrigger < TriggeredAbility
        def should_perform?
          event.player == controller
        end

        def call
          add_counter("+1/+1", to: event.permanent)
        end
      end

      def etb_triggers = [EntersTrigger]
      def event_handlers = { Events::TurnedFaceUp => TurnedFaceUpTrigger }
    end
  end
end
