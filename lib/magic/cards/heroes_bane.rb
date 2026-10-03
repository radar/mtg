module Magic
  module Cards
    HeroesBane = Creature("Heroes' Bane") do
      cost generic: 3, green: 2
      creature_type("Hydra")
      power 0
      toughness 0
    end

    class HeroesBane < Creature
      enters_with_counters "+1/+1", 4

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{2}{G}{G}"

        def resolve!
          trigger_effect(:add_counter, counter_type: "+1/+1", target: source, amount: source.power)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
