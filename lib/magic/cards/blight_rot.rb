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
        add_counter("-1/-1", to: target, amount: 4)
      end
    end
  end
end
