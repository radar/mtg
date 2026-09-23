module Magic
  module Cards
    OnduSpiritdancer = Creature("Ondu Spiritdancer") do
      cost generic: 4, white: 1
      creature_type "Kor Cleric"
      power 3
      toughness 3
    end

    class OnduSpiritdancer < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          enchantment? && under_your_control? &&
            !game.current_turn.events.any? do |event|
              event.is_a?(Events::OnduSpiritdancerCopied) && event.actor == actor
            end
        end

        # The "once per turn" mark must happen here, not in #call: #call is deferred
        # (queued triggers), so the token this creates enters -- and re-dispatches
        # EnteredTheBattlefield to every Spiritdancer, including this one and any
        # other still-pending one -- before #call would otherwise get a chance to
        # record that this Spiritdancer already copied this turn.
        def trigger!
          return false unless should_perform?
          game.current_turn.events << Events::OnduSpiritdancerCopied.new(actor: actor)
          true
        end

        def call
          Permanent.resolve(
            game: game,
            owner: controller,
            card: event.permanent.card,
            token: true,
          )
        end
      end

      def event_handlers
        { Events::EnteredTheBattlefield => EntersTrigger }
      end
    end
  end
end
