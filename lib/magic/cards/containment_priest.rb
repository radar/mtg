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
            return if game.current_turn.events[-3].is_a? Magic::Events::SpellCast
            event.permanent.exile! unless event.permanent.token?
          end
        }
      end
    end
  end
end
