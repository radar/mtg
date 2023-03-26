module Magic
  module Cards
    ContainmentPriest = Creature("Containment Priest") do
      cost generic: 1, white: 1
      creature_type("Human Cleric")
      keywords :flash
      power 2
      toughness 2

      def event_handlers
        {
          Events::EnteredTheBattlefield => -> (receiver, event) do
            return if receiver == event.permanent
            last_action = game.current_turn.actions.last
            return if event.permanent.card == last_action&.card && last_action&.is_a?(Actions::Cast)
            event.permanent.exile! unless event.permanent.token?
          end
        }
      end
    end
  end
end
