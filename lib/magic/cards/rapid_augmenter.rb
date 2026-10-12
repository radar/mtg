module Magic
  module Cards
    RapidAugmenter = Creature("Rapid Augmenter") do
      cost generic: 1, blue: 1, red: 1
      creature_type "Otter Artificer"
      keywords :haste
      power 1
      toughness 3
    end

    class RapidAugmenter < Creature
      # "Whenever another creature you control with base power 1 enters, it gains haste until end of turn."
      class HasteTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && under_your_control? && event.permanent.base_power == 1
        end

        def call
          event.permanent.grant_haste!
        end
      end

      # "Whenever another creature you control enters, if it wasn't cast, put a +1/+1 counter on this creature and
      # this creature can't be blocked this turn." A creature was cast if its card was cast as a spell this turn.
      class NotCastTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && under_your_control? && !cast?
        end

        def cast?
          card = event.permanent.card
          game.current_turn.events.any? { |e| e.is_a?(Events::SpellCast) && e.spell.equal?(card) }
        end

        def call
          trigger_effect(:add_counter, target: actor, counter_type: "+1/+1", amount: 1)
          actor.grant_keyword(Keywords::CANT_BE_BLOCKED)
        end
      end

      def event_handlers
        super.merge(Events::EnteredTheBattlefield => [HasteTrigger, NotCastTrigger])
      end
    end
  end
end
