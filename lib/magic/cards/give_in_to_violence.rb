module Magic
  module Cards
    GiveInToViolence = Instant("Give In to Violence") do
      cost generic: 1, black: 1
    end

    class GiveInToViolence < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        pump(target, 2, 2)
        give_keyword(target, :lifelink)
      end
    end
  end
end
