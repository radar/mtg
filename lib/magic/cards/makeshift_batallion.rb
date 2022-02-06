module Magic
  module Cards
    MakeshiftBatallion = Creature("Makeshift Batallion") do
      type "Human Soldier"
      power 3
      toughness 2
    end

    class MakeshiftBatallion < Creature
      def receive_notification(event)
        case event
        when Events::AttackersDeclared
          return unless event.attackers.include?(self)
          return if event.attackers.count < 3

          add_counter(Counters::Plus1Plus1)
        end
      end
    end
  end
end
