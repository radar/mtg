module Magic
  module Cards
    MakeshiftBatallion = Creature("Makeshift Batallion") do
      cost generic: 2, white: 1
      type "Human Soldier"
      power 3
      toughness 2
    end

    class MakeshiftBatallion < Creature
      def receive_notification(event)
        case event
        when Events::AttackersDeclared
          return unless event.attacks.any? { |attack| attack.attacker == self }
          return if event.attacks.count < 3

          add_counter(Counters::Plus1Plus1)
        end
      end
    end
  end
end
