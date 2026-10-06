module Magic
  module Cards
    Thrive = Sorcery("Thrive") do
      cost x: 1, green: 1
    end

    class Thrive < Sorcery
      def target_choices
        battlefield.creatures
      end

      # "Each of X target creatures": exactly X of them, each a different creature.
      def number_of_targets(x) = x

      def distinct_targets? = true

      # "Put a +1/+1 counter on each of X target creatures."
      def resolve!(targets:)
        targets.uniq.each do |target|
          trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 1)
        end
      end
    end
  end
end
