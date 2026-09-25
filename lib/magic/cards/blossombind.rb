module Magic
  module Cards
    Blossombind = Aura("Blossombind") do
      cost generic: 1, blue: 1
    end

    class Blossombind < Aura
      enchant "Creature"

      def target_choices
        battlefield.creatures
      end

      def prevents_untapping? = true
      def prevents_counters? = true

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:tap, target: actor.attached_to)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
