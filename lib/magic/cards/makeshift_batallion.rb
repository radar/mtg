module Magic
  module Cards
    MakeshiftBatallion = Creature("Makeshift Batallion") do
      cost generic: 2, white: 1
      creature_type("Human Soldier")
      power 3
      toughness 2
    end

    class MakeshiftBatallion < Creature
      def event_handlers
        {
          # Whenever Makeshift Battalion and at least two other creatures attack, put a +1/+1 counter on Makeshift Battalion.
          Events::FinalAttackersDeclared => -> (receiver, event) do
            attacks = event.attacks
            return if attacks.none? { |event| event.attacker == receiver }
            return if attacks.count < 3

            receiver.add_counter(counter_type: Counters::Plus1Plus1)
          end
        }
      end
    end
  end
end
