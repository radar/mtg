module Magic
  module Cards
    UnstoppableSlasher = Creature("Unstoppable Slasher") do
      cost generic: 2, black: 1
      creature_type "Zombie Assassin"
      keywords :deathtouch
      power 2
      toughness 3
    end

    class UnstoppableSlasher < Creature
      # "Whenever this creature deals combat damage to a player, they lose half their life, rounded up."
      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          event.source == actor && event.target.player?
        end

        def call
          player = event.target
          trigger_effect(:lose_life, target: player, life: (player.life / 2.0).ceil) if player.life.positive?
        end
      end

      # "When this creature dies, if it had no counters on it, return it to the battlefield tapped under its owner's
      # control with two stun counters on it." The permanent that died still knows its counters.
      class DiesTrigger < TriggeredAbility::Death
        def should_perform?
          actor.counters.none? && !actor.token? && !actor.copy?
        end

        def call
          card = actor.card
          come_back = lambda do |zone|
            returned = Permanent.resolve(game:, card:, owner: card.owner, from_zone: zone, cast: false, enters_tapped: true)
            returned.add_counter("stun", amount: 2)
          end

          return come_back.call(card.zone) if card.zone&.graveyard?

          OnCardMoved.listen(game:, card:) { |zone| come_back.call(zone) if zone.graveyard? }
        end
      end

      def event_handlers
        { Events::CombatDamageDealt => CombatDamageTrigger }
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
