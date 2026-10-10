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
        trigger_effect(:modify_power_toughness, target: target, power: 2, toughness: 2)
        trigger_effect(:grant_keyword, target: target, keyword: :lifelink)
      end
    end
  end
end
