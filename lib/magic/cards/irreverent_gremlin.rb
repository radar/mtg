module Magic
  module Cards
    IrreverentGremlin = Creature("Irreverent Gremlin") do
      cost generic: 1, red: 1
      creature_type "Gremlin"
      keywords :menace
      power 2
      toughness 2
    end

    class IrreverentGremlin < Creature
      class DiscardChoice < Magic::Choice::Discard
        def resolve!(card:)
          super
          actor.trigger_once_this_turn!(EntersTrigger)
          draw_card
        end
      end

      class MayDiscardChoice < Magic::Choice::May
        def resolve!
          game.choices.add(DiscardChoice.new(actor:, player: controller)) if hand.any?
        end
      end

      # "Whenever another creature you control with power 2 or less enters, you may discard a card. If you do,
      # draw a card. Do this only once each turn." The use is recorded when a card is actually discarded.
      class EntersTrigger < TriggeredAbility
        def should_perform?
          permanent = event.permanent
          permanent != actor && permanent.creature? && permanent.controller == controller && permanent.power <= 2 &&
            !actor.triggered_once_this_turn?(self.class)
        end

        def call
          game.choices.add(MayDiscardChoice.new(actor:)) if hand.any?
        end
      end

      def event_handlers
        super.merge({ Events::EnteredTheBattlefield => EntersTrigger }) { |_, old, new| [*old, *new] }
      end
    end
  end
end
