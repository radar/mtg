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
        add_counter("+1/+1", to: target)
        existing = target.counters.of_type(Magic::Counters::Plus1Plus1).count
        add_counter("+1/+1", to: target, amount: existing)
      end
    end
  end
end
