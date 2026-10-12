module Magic
  module Cards
    Overprotect = Instant("Overprotect") do
      cost generic: 1, green: 1
    end

    class Overprotect < Instant
      def target_choices
        battlefield.controlled_by(controller).creatures
      end

      def resolve!(target:)
        trigger_effect(:modify_power_toughness, target: target, power: 3, toughness: 3)
        trigger_effect(:grant_keyword, target: target, keyword: :trample)
        trigger_effect(:grant_keyword, target: target, keyword: :hexproof)
        trigger_effect(:grant_keyword, target: target, keyword: :indestructible)
      end
    end
  end
end
