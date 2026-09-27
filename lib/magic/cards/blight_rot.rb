module Magic
  module Cards
    BlightRot = Instant("Blight Rot") do
      cost generic: 2, black: 1
    end

    class BlightRot < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        trigger_effect(:add_counter, counter_type: "-1/-1", target: target, amount: 4)
      end
    end
  end
end
