module Magic
  module Cards
    LuminousBroodmoth = Creature("Luminous Broodmoth") do
      cost generic: 2, white: 2
      creature_type "Insect"
      keywords :flying
      power 3
      toughness 4
    end

    class LuminousBroodmoth < Creature
      # "Whenever a creature you control without flying dies, return it to the battlefield under its owner's control
      # with a flying counter on it." A token has nothing to return.
      class ReturnTrigger < TriggeredAbility
        def should_perform?
          dead = event.permanent
          dead.controller == controller && !dead.token? && !dead.flying?
        end

        def call
          card = event.permanent.card
          return unless card.zone&.graveyard?

          card.return_to_battlefield!
          returned = game.battlefield.permanents.find { |permanent| permanent.card.equal?(card) }
          trigger_effect(:add_counter, counter_type: "flying", target: returned, amount: 1) if returned
        end
      end

      def event_handlers = { Events::CreatureDied => ReturnTrigger }
    end
  end
end
