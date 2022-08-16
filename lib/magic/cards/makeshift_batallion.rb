module Magic
  module Cards
    MakeshiftBatallion = Creature("Makeshift Batallion") do
      cost generic: 2, white: 1
      type "Human Soldier"
      power 3
      toughness 2

      def receive_notification(event)
        case event
        when Events::AttackersDeclared
          attackers_declared_events = current_turn.actions.select { |action| action.is_a?(Magic::Actions::DeclareAttacker) }

          return if attackers_declared_events.none? { |event| event.attacker == self }
          return if attackers_declared_events.count < 3

          add_counter(Counters::Plus1Plus1)
        end
      end
    end
  end
end
