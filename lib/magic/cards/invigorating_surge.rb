module Magic
  module Cards
    InvigoratingSurge = Instant("Invigorating Surge") do
      cost generic: 1, green: 1
    end

    class InvigoratingSurge < Instant
      def single_target?
        true
      end

      def target_choices
        controller.creatures
      end

      def resolve!(target:)
        trigger_effect(:add_counter, counter_type: "+1/+1", target: target)
        existing = target.counters.of_type(Magic::Counters::Plus1Plus1).count
        trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: existing)
      end
    end
  end
end
