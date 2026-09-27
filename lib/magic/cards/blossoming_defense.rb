module Magic
  module Cards
    BlossomingDefense = Instant("Blossoming Defense") do
      cost green: 1
    end

    class BlossomingDefense < Instant
      def target_choices
        battlefield.controlled_by(controller).creatures
      end

      def resolve!(target:)
        trigger_effect(:modify_power_toughness, target: target, power: 2, toughness: 2)
        trigger_effect(:grant_keyword, target: target, keyword: :hexproof)
      end
    end
  end
end
