module Magic
  module Cards
    GuardianOfTheHalls = Creature("Guardian of the Halls") do
      cost generic: 1, green: 1
      creature_type("Elf Soldier")
      keywords :trample
      power 2
      toughness 2
    end

    class GuardianOfTheHalls < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{5}{G}{G}"

        def resolve!
          trigger_effect(:add_counter, counter_type: "+1/+1", target: source, amount: 3)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
