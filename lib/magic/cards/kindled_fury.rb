module Magic
  module Cards
    KindledFury = Instant("Kindled Fury") do
      cost red: 1
    end

    class KindledFury < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        pump(target, 1, 0)
        trigger_effect(:grant_keyword, target: target, keyword: :first_strike)
      end
    end
  end
end
