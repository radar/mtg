module Magic
  module Cards
    StarlightSnare = Aura("Starlight Snare") do
      cost generic: 2, blue: 1
    end

    class StarlightSnare < Aura
      enchant "Creature"

      def target_choices
        battlefield.creatures
      end

      def does_not_untap_during_untap_step? = true

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:tap, target: actor.attached_to)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
