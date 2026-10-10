module Magic
  module Cards
    EnduringInnocence = Creature("Enduring Innocence") do
      cost generic: 1, white: 2
      enchantment_creature_type("Sheep Glimmer")
      keywords :lifelink
      power 2
      toughness 1
    end

    class EnduringInnocence < Creature
      # "Whenever one or more other creatures you control with power 2 or less enter, draw a card. This ability
      # triggers only once each turn."
      class SmallCreatureEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && under_your_control? && event.permanent.power <= 2 &&
            !actor.triggered_once_this_turn?(self.class)
        end

        def call
          actor.trigger_once_this_turn!(self.class)
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => SmallCreatureEntersTrigger }

      def death_triggers = [TriggeredAbility::EnduringReturn]
    end
  end
end
