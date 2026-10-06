module Magic
  module Cards
    Hobblefiend = Creature("Hobblefiend") do
      cost generic: 1, red: 1
      creature_type "Devil"
      keywords :trample
      power 2
      toughness 1
    end

    class Hobblefiend < Creature
      # "{1}, Sacrifice another creature: Put a +1/+1 counter on this creature."
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}, Sacrifice another creature"

        def resolve!
          trigger_effect(:add_counter, target: source, counter_type: "+1/+1", amount: 1)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
