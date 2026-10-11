module Magic
  module Cards
    GhostlyKeybearer = Creature("Ghostly Keybearer") do
      cost generic: 3, blue: 1
      creature_type "Spirit"
      keywords :flying
      power 3
      toughness 3
    end

    class GhostlyKeybearer < Creature
      # "Whenever this creature deals combat damage to a player, unlock a locked door of up to one target Room you
      # control."
      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          event.source == actor && event.target.player?
        end

        def call
          choice = Magic::Choice::UnlockDoor.new(actor: actor, optional: true)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::CombatDamageDealt => CombatDamageTrigger }
    end
  end
end
