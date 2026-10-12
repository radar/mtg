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
          add_counter("+1/+1", to: source, amount: 3)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
