module Magic
  module Cards
    MakeshiftBatallion = Creature("Makeshift Batallion") do
      cost generic: 2, white: 1
      creature_type("Human Soldier")
      power 3
      toughness 2
    end

    class MakeshiftBatallion < Creature
      class FinalAttackersDeclaredTrigger < TriggeredAbility
        def should_perform?
          attacks = event.attacks
          return false if attacks.none? { |event| event.attacker == actor }
          return false if attacks.count < 3

          true
        end

        def call
          actor.add_counter(counter_type: Counters::Plus1Plus1)
        end
      end

      def event_handlers
        {
          # Whenever Makeshift Battalion and at least two other creatures attack, put a +1/+1 counter on Makeshift Battalion.
          Events::FinalAttackersDeclared => FinalAttackersDeclaredTrigger
        }
      end
    end
  end
end
