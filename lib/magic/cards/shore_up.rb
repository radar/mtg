module Magic
  module Cards
    ShoreUp = Instant("Shore Up") do
      cost blue: 1
    end

    class ShoreUp < Instant
      def target_choices
        battlefield.controlled_by(controller).creatures
      end

      def resolve!(target:)
        pump(target, 1, 1)
        trigger_effect(:grant_keyword, target: target, keyword: :hexproof)
        target.untap!
      end
    end
  end
end
