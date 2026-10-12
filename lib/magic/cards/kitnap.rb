module Magic
  module Cards
    class Kitnap < Aura
      card_name "Kitnap"
      cost generic: 2, blue: 2
      gift :card

      enchant "Creature"

      def target_choices = battlefield.creatures

      # You control enchanted creature.
      def resolve!(target:)
        target.controller = controller

        super
      end

      # When this Aura enters, tap enchanted creature. If the gift wasn't promised, put three stun
      # counters on it.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          creature = actor.attached_to
          trigger_effect(:tap, target: creature)
          add_counter("stun", to: creature, amount: 3) unless actor.gift_promised?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
